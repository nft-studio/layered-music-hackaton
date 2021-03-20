const HDWalletProvider = require("truffle-hdwallet-provider");
const web3 = require("web3");
require('dotenv').config()
const MNEMONIC = process.env.MNEMONIC;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const NFT_CONTRACT_ABI = require('../build/abi.json')

async function main() {
  const provider = new HDWalletProvider(
    MNEMONIC,
    "http://localhost:7545"
  );
  const web3Instance = new web3(provider);

  const nftContract = new web3Instance.eth.Contract(
    NFT_CONTRACT_ABI,
    NFT_CONTRACT_ADDRESS,
    { gasLimit: "5000000" }
  );
  
  const name = await nftContract.methods.name().call();
  const symbol = await nftContract.methods.symbol().call();
  const owner = await nftContract.methods.owner().call();
  console.log('|* NFT DETAILS *|')
  console.log('>', name, symbol, '<')
  console.log('Owner is', owner)
  
  try {
    console.log('Trying rewarding opera to ...')
    const result = await nftContract.methods
      .rewardTrack('0x9e910D267Db6Dd064b2214Ce0878f83fFc7DE40a', '0x000000000000000000000000000004')
      .send({ from: OWNER_ADDRESS });
    console.log("Minted opera! Transaction: " + result.transactionHash);
    console.log(result)
  } catch (e) {
    console.log(e)
    console.log(e)
  }
  
}

main();
