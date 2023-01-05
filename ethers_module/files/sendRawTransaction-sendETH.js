const ethers = require("ethers");
const { exit } = require("process");
require('dotenv').config();

PROVIDER_URL=process.env.PROVIDER_URL;
PRIVATE_KEY=process.env.PRIVATE_KEY;

(async () => {
  if (process.argv.length != 4) {
    console.error('Expected at least two arguments!');
    process.exit(1);
  }

  console.log(process.argv);

  const toAddress = (process.argv[2] || "") // Read the to address from the arguments, otherwise default to an empty address
  const value = (process.argv[3] || "0") // Read the value from the arguments, otherwise default to 0

  console.log(typeof(value));

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
  // private keys of a ganache account - not a problem at all
  const wallet = new ethers.Wallet(PRIVATE_KEY);
  gasPrice = await provider.getGasPrice()
  
  // Get the nonce of the sender
  nonce = await provider.getTransactionCount(wallet.address);

  let tx = {
    nonce: nonce,
    to: toAddress,	// account #2 --> "0x3782897C2aA7291b148d2C02BB54F7bC84982360"
    value: ethers.utils.parseEther(value),
    gasLimit: 6721975,  // max block gas limit on ganache
    gasPrice: gasPrice,
  };

  let signedTx = await wallet.signTransaction(tx);
  console.log(signedTx);
  let sentTx = await provider.sendTransaction(signedTx);
  console.log(sentTx);
})();
