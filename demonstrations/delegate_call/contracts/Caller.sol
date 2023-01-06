// SPDX-License-Identifier: UNLICENSED
// ONLY FOR DEMONSTRATION PURPOSES, DO NOT USE THIS IN PRODUCTION

import "hardhat/console.sol";

pragma solidity ^0.8.0;

contract Caller {
  uint256 public x;             // Slot 1
  address public logicContract; // Slot 3
  
  event enteredFallback(bool entered);

  constructor(address _logic) {
    logicContract = _logic;
  }
  fallback() external {
    console.log("msg.sender in the Caller contract: ", msg.sender);
    (bool success, ) = logicContract.delegatecall(msg.data);
    require(success, "Unexpected error");
    emit enteredFallback(true);
  }
}
