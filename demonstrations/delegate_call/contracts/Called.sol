// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Called {
  uint256 public x;     // Slot 1

  function increaseX() external {
    x++;
    console.log("msg.sender in the Called contract: ", msg.sender);
  }
}
