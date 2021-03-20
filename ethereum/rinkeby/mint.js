const HDWalletProvider = require("truffle-hdwallet-provider");
const web3 = require("web3");
require('dotenv').config()
const MNEMONIC = process.env.MNEMONIC;
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;
const isInfura = !!process.env.INFURA_KEY;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const NFT_CONTRACT_ABI = require('../build/abi.json')

if (!MNEMONIC || !NODE_API_KEY || !OWNER_ADDRESS || !NETWORK) {
  console.error(
    "Please set a mnemonic, Alchemy/Infura key, owner, network, and contract address."
  );
  return;
}

async function main() {
  const network =
    NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";
  const provider = new HDWalletProvider(
    MNEMONIC,
    isInfura
      ? "https://" + network + ".infura.io/v3/" + NODE_API_KEY
      : "https://eth-" + network + ".alchemyapi.io/v2/" + NODE_API_KEY
  );
  const web3Instance = new web3(provider);

  const nftContract = new web3Instance.eth.Contract(
    NFT_CONTRACT_ABI,
    NFT_CONTRACT_ADDRESS,
    { gasLimit: "10000000", gasPrice: "20000000000" }
  );
  
  const name = await nftContract.methods.name().call();
  const symbol = await nftContract.methods.symbol().call();
  const owner = await nftContract.methods.owner().call();
  console.log('|* NFT DETAILS *|')
  console.log('>', name, symbol, '<')
  console.log('Owner is', owner)

  try {
    console.log('Trying minting opera...')
    const result = await nftContract.methods
      .mintTrack('QmP9A7voVSwb13Q95jJrdBqLdArLwtfexQ3rMEbPbnPS1x')
      .send({ from: OWNER_ADDRESS });
    console.log("Minted opera! Transaction: " + result.transactionHash);
    console.log(result)
  } catch (e) {
    console.log(e)
  }
}

main();
