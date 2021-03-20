const HDWalletProvider = require("truffle-hdwallet-provider");
const web3 = require("web3");
require('dotenv').config()
const MNEMONIC = process.env.MNEMONIC;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
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
    { gasLimit: "10000000" }
  );
  const name = await nftContract.methods.name().call();
  const symbol = await nftContract.methods.symbol().call();
  console.log('|* NFT DETAILS *|')
  console.log('>', name, symbol, '<');

  const owned = await nftContract.methods.ownedTracks().call();
  console.log('TRACK OWNED', owned);

  const canMint = await nftContract.methods.balanceOfMinting().call();
  console.log('N. CAN MINT', canMint);

  process.exit();
}

main();