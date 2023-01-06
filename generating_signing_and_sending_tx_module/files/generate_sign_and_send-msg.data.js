const ethers = require("ethers");
const Web3 = require('web3');

const { exit } = require("process");
require('dotenv').config();

PROVIDER_URL=process.env.PROVIDER_URL;
PRIVATE_KEY=process.env.PRIVATE_KEY;
GAS_LIMIT=process.env.GAS_LIMIT;

/**
 * @param toAddres -> Expected to receive the address that the transaction will be sent to
 * @param value -> Expected to receive the value of ETH to transfer <-> This is script's purpose is to send data not ETHs
 */
(async () => {

  // Initializing web3 object
  const Web3 = require('web3');
  const web3 = new Web3(Web3.givenProvider || PROVIDER_URL);
  // Initializing ethers objects
  const provider = new ethers.providers.JsonRpcProvider(PROVIDER_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY);

  // Initializing variables passed through the arguments
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

  // Reading the value of the variable x in the Logic Contract (Called.sol)
  const calledABI = require("./abis/Called.json")
  const calledContract = new ethers.Contract("0xAe7a6A85738Ed16F77068fc11C2329E528635786",calledABI.abi,provider);

  let x = await calledContract.x()
  console.log("Value of the X variable in the Logic contract at the beginning: ", x.toString())


  // Generating the msg.data
  data = []
  // function_signature_hash = await web3.utils.sha3("initWallet(address[],uint256,uint256)").substring(0,10);
  function_signature_hash = await web3.utils.sha3("increaseX()").substring(0,10);
  //console.log("function_signature_hash", function_signature_hash);
  data.push(function_signature_hash)
  //console.log(data);

  // Putting togheter the function signature and all its arguments
  // The msg_data is basically the function signature hash alongside a number of 32-bytes hexa strings, where each 32-bytes hexa string represent a function's parameter
  msg_data = data.join("")
  //console.log("msg_data", msg_data);


  // Send & Sign transaction process
  gasPrice = await provider.getGasPrice()
  nonce = await provider.getTransactionCount(wallet.address);

  let tx = {
    nonce: nonce,
    to: toAddress,
    value: ethers.utils.parseEther(value),
    gasLimit: parseInt(GAS_LIMIT),
    gasPrice: gasPrice,
    data:msg_data
  };

  let signedTx = await wallet.signTransaction(tx);
  //console.log(signedTx);
  let sentTx = await provider.sendTransaction(signedTx);
  //console.log(sentTx);
  let txResult = await provider.waitForTransaction(sentTx.hash);
  console.log("Transaction sent! - increaseX() from the Logic contract was executed, and the x variable in the Logic Contract was updated");
  //console.log("Transaction Result: ", txResult);

  x = await calledContract.x()
  console.log("Value of the X variable in the Logic contract at the end: ", x.toString())

})();
