// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract Keccak256 {
  
  function debbugingKeccak() public pure returns (uint) {
      return uint256(keccak256(abi.encode(1))) + 1;
  }

  function debbugingKeccakInBytes() public pure returns (bytes32) {
      return bytes32(uint256(keccak256(abi.encode(1))) + 1);
  }

  function operation() public pure returns (uint) {
      return 2**256 - 1;
  }

  function operationInBytes() public pure returns (bytes32) {
      return bytes32(uint256(2**256 - 1));
  }

  function result() public pure returns (uint) {
      return 2**256 - 1 - uint256(keccak256(abi.encode(1))) + 1;
  }

  function resultInBytes() public pure returns (bytes32) {
      return bytes32(2**256 - 1 - uint256(keccak256(abi.encode(1))) + 1);
  }

}