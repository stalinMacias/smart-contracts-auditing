// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const Called = await hre.ethers.getContractFactory("Called");
  const called = await Called.deploy();
  await called.deployed();

  
  const Caller = await hre.ethers.getContractFactory("Caller");
  const caller = await Caller.deploy(called.address);
  await caller.deployed();

  console.log(
    `Logic Contract: ${called.address} \nProxy Contract: ${caller.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
