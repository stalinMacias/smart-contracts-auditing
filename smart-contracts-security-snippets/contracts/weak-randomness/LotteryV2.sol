// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoteryV2 is VRFConsumerBase {
  bytes32 internal keyHash;
  uint256 internal fee;

  uint256 public randomResult;

  constructor()
    VRFConsumerBase(
      0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D, // VRF Coordinator
      0x326C977E6efc84E512bB9C30f76E30c160eD06FB // LINK Token
    )
  {
    keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    fee = 0.1 * 10**18; // 0.1 LINK (Varies by network)
  }

  function getRandomNumber() public returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    randomResult = randomness;
  }

  // function withdrawLink() external onlyOwner {
  //   payable(owner).transfer(address(this).balance)
  // }
}
