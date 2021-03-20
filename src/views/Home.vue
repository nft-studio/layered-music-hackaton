<template>
  <div class="home" style="padding: 5vh 30%; font-size: 22px">
    <img src="/img/layered-music-logo.png" style="height:150px;" /><br />
    <hr />
    <div v-if="!account">
      Please connect your Metamask wallet first,<br />window should be open
      automatically or click below button.<br /><br />
      <b-button type="is-primary" v-on:click="connect">CONNECT METAMASK</b-button>
    </div>
    <div v-if="account">
      <b>Welcome back</b><br /><i style="font-size: 12px">{{ account }}</i>
    </div>
  </div>
</template>

<script>
var Web3 = require("web3");
const ABI = require("../util/abi.json");
const axios = require("axios");
import * as Tone from "tone";
export default {
  name: "Home",
  data() {
    return {
      tone: Tone,
      axios: axios,
      web3: new Web3(window.ethereum),
      contractAddress: process.env.VUE_APP_SMART_CONTRACT_ADDRESS,
      account: "",
      contract: {},
      fileToMint: {},
      isUploadingIPFS: false,
      isUploadingMetadata: false,
      isMinting: false,
    };
  },
  mounted() {
    this.connect();
  },
  methods: {
    async connect() {
      window.ethereum.enable();
      let accounts = await this.web3.eth.getAccounts();
      let contract = await new this.web3.eth.Contract(
        ABI,
        this.contractAddress,
        {
          gasLimit: "5000000",
        }
      );
      this.contract = contract;
      this.account = accounts[0];
    },
  },
};
</script>
