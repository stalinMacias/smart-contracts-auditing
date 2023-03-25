pragma solidity 0.7.0;

/*
@audit-info => This contract has not a mechanism to withdraw the received ETH
@audit-info => Missing an event to be implemented when a transfer() is performed

@audit-info => There is any validation to ensure the MAX_SUPPLY is not surpassed
            => MAX_SUPPLY is set to 100 ETH, if each ETH mints 10 tokens, the totalSupply of tokens must be 1000 tokens
            @audit-issue => The lack of this validation could lead to mint infinite tokens
*/
contract InSecureumToken {

mapping(address => uint) private balances;

//@audit-info => decimal is declared as a state variable nad has public visibility
//@audit => Suggestion to set it as a CONSTANT
uint public decimals = 10**18; // decimals of the token

//@audit-info => totalSupply is declared as public, which in instance creates a setter for the variable, thus, the function could be updated by an unauthorized party
//@audit-info => totalSupply is not initialized, starts in 0
//@audit => totalSupply should be a private variable that must require a control access in case it needs to be modified
uint public totalSupply; // total supply

// @audit-info => variable visibility is not defined, thus, is set as internal by default
// @audit => Explicitly define the desired visibility of the variable
// @audit => Consider setting this variable as a CONSTANT if it won't be required to update its value
uint MAX_SUPPLY = 100 ether; // Maximum total supply

event Mint(address indexed destination, uint amount);

//@audit-info => function visibility is set to public, but this function is not expected to be called from any other function within this contract
//@audit => Suggested to change the visibility to external
function transfer(address to, uint amount) public {
   // save the balance in local variables
   // so that we can re-use them multiple times
   // without paying for SLOAD on every access
   uint balance_from = balances[msg.sender];
   uint balance_to = balances[to];
   require(balance_from >= amount);
   balances[msg.sender] = balance_from - amount;
   balances[to] = safeAdd(balance_to, amount);
}


/// @notice Allow users to buy token. 1 ether = 10 tokens
/// @dev Users can send more ether than token to be bought, to donate a fee to the protocol team.
function buy(uint desired_tokens) public payable {
   //@audit-info => Unsafe rounding?
   // Check if enough ether has been sent
   uint required_wei_sent = (desired_tokens / 10) * decimals;
   //@note => msg.value is expressed in weis
   require(msg.value >= required_wei_sent);

   // Mint the tokens
   totalSupply = safeAdd(totalSupply, desired_tokens);
   balances[msg.sender] = safeAdd(balances[msg.sender], desired_tokens);
   emit Mint(msg.sender, desired_tokens);
}


/// @notice Add two values. Revert if overflow
function safeAdd(uint a, uint b) pure internal returns(uint) {
   if (a + b < a) {
      revert();
   }
   return a + b;
}
}