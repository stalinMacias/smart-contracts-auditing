// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LaunchPad is ERC20 {
    address owner;
    uint private totalPoolToken;
    address[] public lauchpadParticipants;
    //@audit-info => Unnused variable <-> Missed to add it as require() in the launchDeposit()
    uint public minimumAmt = 0.1 ether;
    mapping(address => bool) public participated;

    struct launchDetails {
        uint startTime;
        uint duration;
        uint endLaunch;
        bool inProgress;
    }

    launchDetails public launchpad;

    constructor() ERC20("Ogeni", "OGN") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    //@audit-info => This function can be called multiple times by the owner, even though the totalPoolToken has already been initialized, thus totalPoolToken could be manipulated
    //@audit => Consider using a flag to prevent the function being called more than once
    function setTokenDistribution(
        uint _amount
    ) public onlyOwner returns (uint) {
       //@audit-info Why multiplying the _amount times 1 ether, this will result in a huge amount of tokens ...
       // Example, Owner intends to set the amount to be 10, in reality, this function will set the totalPoolToken to be 100000000000... (10 * (10 ** 18))
       // For Reference: https://www.alchemy.com/gwei-calculator
       //@audit => Recommendation should be to set the totalPoolToken using the value of the _amount parameter to prevent unexpected calculations
        totalPoolToken = _amount * 1 ether;
    }

    //@audit-info => Consider implementing a mechanism that will be aware if a launch pad was already created and ended, and the totalPoolToken was drain downed to 0....
    //@audit -> The current mechanism would allow to start infinite times the launch pad
    //@audit-issue => POC: A launch pad has ended, owner calls setTokenDistribution() and set totalPoolToken again to 0, owner calls again the startSales() again and the launchpad functions are enabled again, thus allowing to buy tokens at a discount!
    function startSales() public onlyOwner {
        require(totalPoolToken != 0, "Set setTokenDistribution");
        launchDetails memory _launch;
        _launch.startTime = block.timestamp;
        _launch.duration = 3 minutes;
        _launch.endLaunch = _launch.startTime + 3 minutes;
        _launch.inProgress = true;

        launchpad = _launch;
    }

    //@audit => Consider updating the function visibility to external, since any other function of this contract is expected to call this one!
    function launchDeposit() public payable {
        require(msg.value > 0, "Insufficient particitpation fund");
        //@audit-info => This check is not required at all, the zero address can't initiate transactions :)
        //@audit => This check is required when the parameter being validated would be the receiver of some tokens/ETH
        require(msg.sender != address(0), "Address zero!!!!");
        require(totalPoolToken > 0, "launchPad token exhausted");
        //@audit => Consider checking what unit will be used for the totalPoolToken, this check assumes that each token costs 1 wei!
        require(
            msg.value <= totalPoolToken,
            "Not enough tokens left, consider reducing purchase amount"
        );
        //@audit => consider moving the below 4 lines at the very beginning of this function, if the endLaunch time has already reach there is no point in running any of the other validations!
        if (block.timestamp > launchpad.endLaunch) {
            launchpad.inProgress = false;
        }
        require(launchpad.inProgress == true, "LaunchPad ended");

        uint transferAmt = tokenEquivalent();
        _mint(msg.sender, transferAmt);
        totalPoolToken -= transferAmt;
        //@audit => Is this validation intended to prevent the same user to participate multiple times in the launchpad? If so, this check won't actually achieve that!
        if (participated[msg.sender] != true) {
            lauchpadParticipants.push(msg.sender);
        }
    }

    function retreiveFunds() public payable onlyOwner {
        if (block.timestamp > launchpad.endLaunch) {
            launchpad.inProgress = false;
        }
        require(launchpad.inProgress == false, "Sales in progress");
        uint _amount = withdrawFunds();
        //@audit => Consider updating the receiver adress from msg.sender to the owner variable!
        (bool sent, bytes memory data) = address(msg.sender).call{
            value: _amount  //@audit => There is no point in calling another function to retrieve the address(this).balance
        }("");
        require(sent, "Failed to send Ether");
    }

    //@audit => as per comment in line 93, this function can be removed
    function withdrawFunds() internal view returns (uint) {
        uint contractBal = address(this).balance;
        return contractBal;
    }

    function tokenEquivalent() internal returns (uint) {
        //@audit-info => Multiplying any value by 1 will result in the same value... is it missing to specify an specific unit (eth,wei....)?
        uint equiAmt = msg.value * 1;
        return equiAmt;
    }
}