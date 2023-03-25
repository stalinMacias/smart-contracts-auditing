// SPDX-License-Identifier: agpl-3.0
//@audit-info => Unlocked pragma, could result in using different compiler's version for testing and for deploying
//@audit => The recommendation is to lock the pragma version to a specific solidity version
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";

contract SimpleDEX {
   //@audit-info => Why is this variable defined as an uint64? Is not even packing in the storage... The whole slot will be end up be used only by this variables...
   uint64 public token_balance;
   uint256 public current_eth;
   IERC20 public token;
   //@audit-info => Unnused variable
   uint8 public reentrancy_lock;
   address owner;
   uint256 public fees;
   //@audit => Could be declared as CONSTANT <=> Saves some gas
   uint256 public immutable fees_percentage = 10;

   //@audit-issue => Missing logic => Reentrancy is not prevented
   modifier nonReentrant(){
     // Logic needs to be implemented    
       _; 
   }
  
   modifier onlyOwner(){
       //@audit-issue => Using tx.origin to validate access control can lead to Man-In-The-Middle attacks
       //@audit => Always prefer to use msg.sender over tx.origin for validations involved in access control
       require(tx.origin == owner, "Only owner permitted");
       _;
   }

    constructor(uint first_balance, address _token, address _owner) payable {
        require(_owner != address(0) , "No zero Address allowed");
        //@audit-info => msg.value is expressed in wei and the validation is not specifying an specific ETH unit to make the comparisson
        //@audit-info => The requirement might be expecing to receive 100ETH, but if the deployer sends only 100wei the conditional will be true
        //@audit-info => POC => https://gist.github.com/stalinMacias/58b367a81df7972286d0d2a149b607f0
        require(msg.value >= 100);
        token = IERC20(_token);
        bool token_success = token.transferFrom(msg.sender, address(this), first_balance);
        require (token_success, "couldn't transfer tokens");
        owner = _owner;
        //@audit-info => downcasting an uin256 to an uint64 could mess up the original value
        //@audit-info => POC => https://gist.github.com/stalinMacias/25d3a654a74e69436b52cd7df00f5d9b
        token_balance = uint64(first_balance);
        //@audit-info => msg.value is expressed in wei
        //@audit-info => If the value of current_eth is handled as if each unit represents an entire ETH it will cause problems because the value is actually representing 1wei
        current_eth = msg.value;
    }

   //@audit-info => Wrong implementation of the onlyOwner modifier could leat to Man-In-The-Middle attacks
   function setOwner(address _owner) public onlyOwner {
       owner = _owner;
   }

   //@audit => Function visibility could be set to external
   function getTokenBalance() public view returns(uint64 _token_balance) {
       _token_balance = token_balance;
   }

   //@audit => Function visibility could be set to external
   function getCurrentEth() public view returns(uint256 _current_eth) {
       _current_eth = current_eth;
   }

   function getEthPrice() public view returns(uint) {
       //@audit-info => Bad rounding because of the division could return an incorrect ETH price
       //@audit-info => current_eth variable actually represents the total wei stored in the contract, not the total ETH!
       return uint256(token_balance) / current_eth;
   }

   //@audit-info => Wrong implementation of the onlyOwner modifier could leat to Man-In-The-Middle attacks
   //@audit => Function visibility could be set to external
   function claimFees() public onlyOwner {
       //@audit-info => destination address is msg.sender instead of being the owner
       //@audit-info => If the onlyOwner modifier is bypassed, a malitious contract could call this function and being able to receive the fees because in that scenario, msg.sender would be malitious contract
       //@audit => The suggestion it is to use the owner variable as the destination address
       bool token_success =  token.transfer(msg.sender, fees);
       require(token_success, "couldn't transfer tokens");
       //@audit-info => downcasting an uin256 to an uint64 could mess up the original value
       //@audit-info => This could lead to missing fees
       token_balance -= uint64(fees); 
       fees = 0;
   }

    //@audit-issue => the nonReentrant modifier didn't implemented any logic, thus, this functions is succeptible to reentrancy
    //@audit-issue => function visibility is not explictly defined, thus, its default value is set to public
    //@audit => Function name indicates that this function allows to buy ETH, but the logic in place is dealing with WEIs and is not making any convertions to ETH...
    //@audit => The caller receives ETH and gives tokens => The caller is selling tokens in exchange of ETH => The caller is buying ETH using tokens or The contract is buying tokens using ETH
   function buyEth(uint amount) external nonReentrant {
       //@audit-info => Does the user wants to buy 10ETH, 10WEI, 10 what?
       //@audit-info => Any operation performed involving the current_eth variable will be dealing with WEIs instead of ETHs
       require(amount >= 10);
       //@audit-info => ratio is not accurately representing the ETH price per token, instead represents the WEI price per token!
       uint ratio = getEthPrice();
       //@audit-info => Bad rounding because of the division
       //@audit => The best practice is to perform first the Multiplication operations followed by any division that is required
       uint fee = (amount / 100) * fees_percentage;
       //@audit-info => token_amount is not accurately representing the ETH price per token, instead represents the WEI price per token!
       uint token_amount = ratio * (amount + fee);
       bool token_success = token.transferFrom(msg.sender, address(this), token_amount);
       current_eth -= amount;
       require(token_success, "couldn't transfer tokens");
       (bool success, ) = msg.sender.call{value: amount}("");
       require(success, "Failed to transfer Eth");
       //@audit-info => downcasting an uin256 to an uint64 could mess up the original value
       //@audit-issue => If a downcast happens, the token_balance variable won't accurately reflect the total tokens held by this contract
       token_balance += uint64(token_amount);
       //@audit-info => Why is the fee variable multiplied by the ratio? Isn't ratio express the ETH price (WEI) per token? 
       //@audit-info => Isn't fees claimed in tokens instead of ETHs?
       //@audit-issue => fees is misscalculated and will cause the fees to be more than what they really should be / Contract's owner beneffits from this bug
       fees += ratio * fee; 
   }

   fallback() payable external {
       revert();
   }
}


contract SimpleDexProxy {
   function buyEth(address simpleDexAddr, uint amount) external {
       require(amount > 0, "Zero amount not allowed");
       //@audit-info => buyEth function doesn't return any value!
       (bool success, ) = (simpleDexAddr).call(abi.encodeWithSignature("buyEth(uint)", amount));
       require (success, "Failed");
   }
}


contract Seller {
        // Sells tokens to the msg.sender in exchange for eth, according to SimpleDex's getEthPrice() 
        function buyToken(SimpleDEX simpleDexAddr) external  payable {
            uint ratio = simpleDexAddr.getEthPrice();
            IERC20 token = simpleDexAddr.token(); 
            uint256 token_amount = msg.value * ratio;
            //@audit-info => Calling directly the transfer() of the ERC20 token, it will basically transfer the caller's token to the msg.sender
            //@audit-issue => By transfering the tokens directly with the transfer() the function is basically gifting those tokens because it won't get anything in return
            //@audit => This function should've called the buyEth() of the SimpleDex contract instead of the transfer() of the ERC20 contract => simpleDexAddr.buyEth(amount);
            token.transfer(msg.sender, token_amount);
        }
}