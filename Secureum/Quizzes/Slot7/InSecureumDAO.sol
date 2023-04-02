pragma solidity 0.8.4;
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol';
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";

contract InSecureumDAO is Pausable, ReentrancyGuard {
    
    // Assume that all functionality represented by ... below is implemented as expected
     
    address public admin;
    mapping (address => bool) public members;
    mapping (uint256 => uint8[]) public votes;
    mapping (uint256 => uint8) public winningOutcome;
    uint256 memberCount = 0;
    //@audit => 1000 what? ETH, USDC, USDT....
    //@audit-info => After reading the code looks like the 1000 refers to wei == 1000 weis is the fee to join the DAO!
    uint256 membershipFee = 1000;
     
    modifier onlyWhenOpen() {
        //@audit => The balance of the DAO contract can be altered by forcing an ETH send into this contract, thus, this modifier would not work as intended because it will bypass the security check if the DAO has been opened
        //@audit-info => A better check would be to use a boolean flag that is only set to true when the admin initializes the DAO!
        //require(isOpen,"The DAO is closed");
        require(address(this).balance > 0, 'InSecureumDAO: This DAO is closed');
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier voteExists(uint256 _voteId) {
       // Assume this correctly checks if _voteId is present in votes
        ...
        _;
    }
    
    constructor (address _admin) {
        //@audit => Incorrect validation, require() is forcing the admin address to be the 0x addres
        //@audit-issue => Missued operator, should be used != instead of ==
        require(_admin == address(0));
        admin = _admin;
    }
  
    function openDAO() external payable onlyAdmin {
        // Admin is expected to open DAO by making a notional deposit
        ...
    }

    function join() external payable onlyWhenOpen nonReentrant {
        require(msg.value == membershipFee, 'InSecureumDAO: Incorrect ETH amount');
        members[msg.sender] = true;
        ...
    }

    //@audit-issue => Missing use of voteExists() modifier!
    //@audit-issue => Anybody can create a vote even though they are not members of the DAO
    function createVote(uint256 _voteId, uint8[] memory _possibleOutcomes) external onlyWhenOpen whenNotPaused {
        //@audit => Missing validation if the _voteId has been already used
        //@audit-info => If an existing vote has been created using this _voteId, the below line will wipe out the previous vote!
        votes[_voteId] = _possibleOutcomes;
        ...
    }

    //@audit-issue => Anybody can cast a vote even though they are not members of the DAO
    function castVote(uint256 _voteId, uint8 _vote) external voteExists(_voteId) onlyWhenOpen whenNotPaused {
        ...
    }

    function getWinningOutcome(uint256 _voteId) public view returns (uint8) {
        // Anyone is allowed to view winning outcome
        ...
        return(winningOutcome[_voteId]);
    }
  
    //@audit-info => Should emit an event to notify and keep track of the membership fee changes?
    function setMembershipFee(uint256 _fee) external onlyAdmin {
        membershipFee = _fee;
    }
  
    //@audit-issue => Wrong implementation, the function is intended to delete all the members of the DAO but it will only delete the admin!
    function removeAllMembers() external onlyAdmin {
        //@audit-info => The below line will delete the caller from the members mapping, which the caller happens to be the admin!
        delete members[msg.sender];
    }  
}