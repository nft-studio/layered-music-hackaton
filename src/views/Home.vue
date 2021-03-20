<template>
  <div class="home" style="padding: 5vh 30%; font-size: 22px">
    <img src="/img/layered-music-logo.png" style="height: 150px" /><br />
    <hr />
    <div v-if="!account">
      Please connect your Metamask wallet first,<br />window should be open
      automatically or click below button.<br /><br />
      <b-button type="is-primary" v-on:click="connect"
        >CONNECT METAMASK</b-button
      >
    </div>
    <div v-if="account">
      <b>Welcome back</b><br /><i style="font-size: 12px">{{ account }}</i>
      <br />
      <hr />
      <div class="row" style="padding-top: 15px">
        <div class="columns">
          <div class="column">
            <b-tabs
              v-model="activeTab"
              expanded
              :animated="false"
              type="is-toggle-rounded"
            >
              <b-tab-item label="Mint new track">
                <hr />
                <div style="text-align: center">
                  <div v-if="balanceMinting > 0">
                    You can mint {{ balanceMinting }} tracks.<br />
                    <b-button>Generate random seed</b-button>
                  </div>
                  <div v-if="balanceMinting === 0">
                    You must pay 0.05 ETH for each track, please select how many
                    tracks do you want to buy:
                    <br />
                    <b-numberinput v-model="howMuchBuy"></b-numberinput>
                    <br />
                    <b-button v-on:click="buyMintings"
                      >Buy {{ howMuchBuy }} tracks for
                      {{ (howMuchBuy * 0.05).toFixed(2) }} ETH</b-button
                    >
                  </div>
                </div>
              </b-tab-item>

              <b-tab-item label="Your NFT tracks">
                <hr />
                {{ nftOwned }}
              </b-tab-item>
            </b-tabs>
          </div>
        </div>
      </div>
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
      howMuchBuy: 1,
      seedToMint: "",
      collectionToMint: "",
      collections: ["0xJitzu"],
      nftOwned: [],
      balanceMinting: 0,
      isMinting: false,
      activeTab: 0,
    };
  },
  async mounted() {
    await this.connect();
    await this.checkContractUserState();
  },
  methods: {
    connect() {
      const app = this;
      return new Promise(async (response) => {
        window.ethereum.enable();
        let accounts = await app.web3.eth.getAccounts();
        let contract = await new app.web3.eth.Contract(
          ABI,
          app.contractAddress,
          {
            gasLimit: "5000000",
          }
        );
        app.contract = contract;
        app.account = accounts[0];
        response(true);
      });
    },
    async checkContractUserState() {
      const app = this;
      if (app.account !== "") {
        try {
          let owned = await app.contract.methods.ownedTracks().call({ from: app.account });
          app.nftOwned = owned;
        } catch (e) {
          alert(e);
        }
        try {
          let balanceMinting = await app.contract.methods
            .balanceOfMinting()
            .call({ from: app.account });
          app.balanceMinting = parseInt(balanceMinting);
        } catch (e) {
          alert(e);
        }
      }
    },
    async buyMintings() {
      const app = this;
      const ethAmount = (app.howMuchBuy * 0.05).toFixed(2);
      try {
        const tx = await app.contract.methods.buyMinting().send({
          from: app.account,
          value: app.web3.utils.toWei(ethAmount, "ether"),
        });
        console.log(tx);
        alert("You just bought " + app.howMuchBuy + " tracks");
        app.howMuchBuy = 1;
        app.checkContractUserState();
      } catch (e) {
        alert("Something went wrong!");
      }
    },
  },
};
</script>
