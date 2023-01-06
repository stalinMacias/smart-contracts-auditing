require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
      blockGasLimit: 20000000,
      /*
      mining: {
        auto: false,
        interval: 5000,
      },
      */
    },
    ganache: {
      url: "HTTP://172.27.224.1:7545",
      accounts: ["8b560f49ab01797582a5079ceb2ed5480f9d72c954f2d72e15299f970db365c6"], // account's address -> 0x98A906664d1045c64ab61d644CCbaCf168A67d5c
    },
  },
};
