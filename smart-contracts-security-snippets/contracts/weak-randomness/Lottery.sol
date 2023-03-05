// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";


contract Lottery is Ownable {
    using Address for address payable;

    uint8 public winningNumber;
    mapping(address => uint8) public bets;
    bool public betsClosed;
    bool public prizeTaken;

    function placeBet(uint8 _number) external payable {
        require(bets[msg.sender] == 0, "Only one bet per user");
        require(msg.value == 1 ether, "1 ETH to enter the lottery");
        require(betsClosed == false, "Bets are closed");
        require(_number > 0 && _number <= 255, "Must be a number from 1 to 255");

        bets[msg.sender] = _number;
    }

    function endLottery() external onlyOwner {
        betsClosed = true;
        winningNumber = pseudoRandNumGen();
    }

    function withdrawPrize() external{
        require(betsClosed == true, "Bets are still running");
        require(prizeTaken == false, "Prize has already been taken");
        require(bets[msg.sender] == winningNumber, "You are not the winner");

        prizeTaken = true;

        payable(msg.sender).sendValue(address(this).balance);
    }


    function pseudoRandNumGen() private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encode(block.timestamp))) % 254) + 1;
    }


}