const ethers = require("ethers");
(async () => {
  const provider = new ethers.providers.JsonRpcProvider("HTTP://172.27.224.1:7545");
  // private keys of a ganache account - not a problem at all
  const wallet = new ethers.Wallet("8b560f49ab01797582a5079ceb2ed5480f9d72c954f2d72e15299f970db365c6");
  gasPrice = await provider.getGasPrice()
  
  // Get the nonce of the sender
  nonce = await provider.getTransactionCount(wallet.address);

  let tx = {
    nonce: nonce,
    to: "0x3782897C2aA7291b148d2C02BB54F7bC84982360",	// account #2
    value: ethers.utils.parseEther("1"),
    gasLimit: 6721975,
    gasPrice: gasPrice,
  };

  let signedTx = await wallet.signTransaction(tx);
  console.log(signedTx);
  let sentTx = await provider.sendTransaction(signedTx);
  console.log(sentTx);
})();
