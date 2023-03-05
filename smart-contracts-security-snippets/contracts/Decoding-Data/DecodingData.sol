// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecodingData {
  
  function encodeData(uint x, address me, uint[2] calldata numbers) external pure returns (bytes memory) {
     
    // Encoding the three above variables 
    bytes memory data = abi.encode(x,me,numbers);
    
    return data;
  }

  function decodeData(bytes calldata data) external pure returns (uint x, address me, uint[2] memory arr) {
    (x, me, arr) = abi.decode(data, (uint, address, uint[2]));
  }

}