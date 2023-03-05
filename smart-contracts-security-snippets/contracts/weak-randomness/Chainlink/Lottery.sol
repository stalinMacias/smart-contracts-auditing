// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";


interface IVRFv2Consumer {
  function requestRandomWords() external returns (uint256);
  function transferOwnership(address recipient) external;
  function acceptOwnership() external;
}

contract Lottery is Ownable {
  using Address for address payable;

  IVRFv2Consumer public vrfV2Consumer;

  // Keep track of the number that each player bets for
  mapping(address => uint8) public bets;
  // Prevent that the same number can be used by different players
  mapping(uint => bool) public takenNumbers;

  uint256 public winningNumber;

  bool requestedRandomNumber;
  bool betsClosed;
  bool prizeTaken;

  constructor(address _VRFv2ConsumerAddress) {
    vrfV2Consumer = IVRFv2Consumer(_VRFv2ConsumerAddress);
  }

  function placeBet(uint8 _number) external payable {
    require(bets[msg.sender] == 0, "Only one bet per player");
    require(takenNumbers[_number] == false, "The selected number has been already taken by another player, choose a different number");
    require(msg.value == 1 ether, "Bet cost: 1 ether");
    require(betsClosed == false, "Bets are closed");
    require(_number > 0 && _number <= 255, "Must be a number from 1 to 255");

    bets[msg.sender] = _number;
    takenNumbers[_number] = true;
  }

  function endLottery() external onlyOwner {
    require(requestedRandomNumber == false, "Random Number has already been requested");
    betsClosed = true;
    requestedRandomNumber = true;
    winningNumber = uint8(uint256(requestRandomNumber()));
  }

  function withdrawPrize() external {
    require(betsClosed == true, "Bets are still running");
    require(prizeTaken == false, "Prize already taken");
    require(bets[msg.sender] == winningNumber, "You aren't the winner");

    prizeTaken = true;

    payable(msg.sender).sendValue(address(this).balance);
  }

  // Functions to interact with the vrfv2 contract - Chainlinks consumer 

  function requestRandomNumber() internal returns (uint256) {
    return vrfV2Consumer.requestRandomWords();
  }

  function acceptOwnershipOfConsumerBaseContract() external onlyOwner {
    vrfV2Consumer.acceptOwnership();
  }

  function transferOwnershipOfConsumerBaseContract(address _newOwner) external onlyOwner {
    vrfV2Consumer.transferOwnership(_newOwner);
  }

  // This function was created only for the demo - The contract's owner will withdraw all the ETH that was betted on this contract
  // Goerli ETH nowadays is more difficult to get : )
  function getBackGoerliETH() external onlyOwner {
    payable(owner()).sendValue(address(this).balance);
  }

}
