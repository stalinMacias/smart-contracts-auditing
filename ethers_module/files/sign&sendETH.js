const ethers = require("ethers");
const { exit } = require("process");
require('dotenv').config();

PROVIDER_URL=process.env.PROVIDER_URL;
PRIVATE_KEY=process.env.PRIVATE_KEY;
GAS_LIMIT=process.env.GAS_LIMIT;

/**
 * @param toAddres -> Expected to receive the address that the transaction will be sent to
 * @param value -> Expected to receive the value of ETH to transfer
 */

(async () => {
  if (process.argv.length != 4) {
    console.error('Expected at least two arguments!');
    process.exit(1);
  }

  const toAddress = (process.argv[2] || "") // Read the to address from the arguments, otherwise default to an empty address
  const value = (process.argv[3] || "0") // Read the value from the arguments, otherwise default to 0

  // Validate toAddress & value were properly initialized
  if (toAddress == "") {
    console.log("Error initializing the to address");
    process.exit()
  }
  if (value == "0") {
    console.log("Error initializing the value to send");
    process.exit()
  }

  const provider = new ethers.providers.JsonRpcProvider(PROVIDER_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY);
  
  gasPrice = await provider.getGasPrice()
  nonce = await provider.getTransactionCount(wallet.address);

  let tx = {
    nonce: nonce,
    to: toAddress,
    value: ethers.utils.parseEther(value),
    gasLimit: parseInt(GAS_LIMIT),
    gasPrice: gasPrice,
  };

  let signedTx = await wallet.signTransaction(tx);
  //console.log(signedTx);
  let sentTx = await provider.sendTransaction(signedTx);
  //console.log(sentTx);
  let txResult = await provider.waitForTransaction(sentTx.hash);
  console.log("Transaction Result: ", txResult);
})();
