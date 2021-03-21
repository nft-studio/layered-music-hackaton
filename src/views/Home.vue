<template>
  <div class="container" style="padding: 5vh 10%; font-size: 22px">
    <div style="height: 40px">
      <img
        src="/img/layered-music-logo.png"
        style="height: 50px; float: left"
      />
      <i style="font-size: 12px; margin-top: 22px; float: right">{{
        account
      }}</i>
    </div>
    <hr />
    <div v-if="!account">
      Please connect your Metamask wallet first,<br />window should be open
      automatically or click below button.<br /><br />
      <b-button type="is-primary" v-on:click="connect"
        >CONNECT METAMASK</b-button
      >
    </div>
    <div v-if="account">
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
                    You can mint {{ balanceMinting }} tracks,
                    {{ trackCounts }} were created yet by other people.<br />
                    <Grid :layers="layers" />
                    <div style="font-size: 12px">{{ seed }}</div>
                    <br />
                    <b-button style="float: left" v-on:click="generateSeed"
                      >Generate random seed</b-button
                    >
                    <b-button
                      style="float: right"
                      v-if="seedFound && !isMinting"
                      v-on:click="mintSeed"
                      >Mint seed!</b-button
                    >
                    <b-button
                      style="float: right"
                      v-if="seedFound && !isPlaying"
                      v-on:click="playSeed"
                      >Play seed!</b-button
                    >
                    <b-button
                      style="float: right"
                      v-if="seedFound && isPlaying"
                      v-on:click="stop"
                      >Stop seed!</b-button
                    >
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
import Grid from "@/components/Grid.vue";
var Web3 = require("web3");
var sha256 = require("sha256");
const ABI = require("../util/abi.json");
const axios = require("axios");
import * as Tone from "tone";
export default {
  name: "Home",
  components: {
    Grid,
  },
  data() {
    return {
      tone: Tone,
      axios: axios,
      web3: new Web3(window.ethereum),
      contractAddress: process.env.VUE_APP_SMART_CONTRACT_ADDRESS,
      account: "",
      contract: {},
      howMuchBuy: 1,
      seed: "",
      collectionToMint: "0xJitzu",
      collections: ["0xJitzu"],
      nftOwned: [],
      balanceMinting: 0,
      isMinting: false,
      seedFound: false,
      isPlaying: false,
      activeTab: 0,
      trackCounts: 0,
      layers: [
        { l: 1, v: 1 },
        { l: 2, v: 2 },
        { l: 3, v: 3 },
        { l: 4, v: 4 },
        { l: 5, v: 5 },
        { l: 6, v: 6 },
      ],
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
          let owned = await app.contract.methods
            .ownedTracks()
            .call({ from: app.account });
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

        try {
          let trackCounts = await app.contract.methods
            .trackCounts()
            .call({ from: app.account });
          app.trackCounts = parseInt(trackCounts);
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
    async generateSeed() {
      const app = this;
      if(app.isPlaying){
        app.stop()
      }
      let distributions = [0, 0, 0, 0, 0, 0];
      let retries = 0;
      let max = 1;
      let found = false;
      try {
        while (!found) {
          retries++;
          if (retries % 36 === 0) {
            console.log('Lowering difficulty.')
            if(max <= 6){
              max++;
            }
          }
          // Calling random function
          let seed = await app.contract.methods
            .createRandomSeed(new Date().getTime())
            .call({ from: app.account });
          app.seed = seed;
          // Extracting layers
          app.extractLayers();
          found = true;

          // Calculating distribution
          for (let j in app.layers) {
            let k = app.layers[j].v - 1;
            distributions[k]++;
          }
          for (let i in distributions) {
            if (distributions[i] >= max) {
              found = false;
              distributions = [0, 0, 0, 0, 0, 0];
            }
          }

          // Checking if seed was minted before
          if (found) {
            let finalseed = sha256(JSON.stringify(app.layers));
            let owned = await app.contract.methods
              .ownerTrack(finalseed)
              .call({ from: app.account });
            if (owned !== "0x0000000000000000000000000000000000000000") {
              found = false;
            } else {
              app.seedFound = true;
            }
          }
        }
      } catch (e) {
        alert(e);
      }
    },
    async extractLayers() {
      const app = this;
      const seed = app.seed.replace("0x", "");
      let keys = [];
      let i = 0;
      let j = 0;
      for (let k in seed) {
        const decimal = parseInt(seed[k], 16);
        if (i < 6) {
          if (keys[j] === undefined) {
            keys[j] = decimal;
          } else {
            keys[j] += decimal;
            i++;
          }
        } else {
          j++;
          i = 0;
        }
      }
      for (let k in keys) {
        let lower = keys[k];
        while (lower > 6) {
          lower = parseInt(lower / 6);
        }
        if (app.layers[k] !== undefined) {
          app.layers[k].v = lower;
        }
      }
    },
    makeChannel(track, pan) {
      const app = this;
      return new Promise((response) => {
        console.log("Adding " + track);
        const channel = new Tone.Channel({
          pan,
        }).toDestination();
        const player = new Tone.Player({
          url: "/layers/" + app.collectionToMint + "/layer" + track + ".wav",
          loop: true,
        })
          .sync()
          .start();
        player.connect(channel);
        Tone.loaded().then(() => {
          console.log('Track loaded')
          response(true);
        });
      });
    },
    async playSeed() {
      const app = this;
      await Tone.start();
      const toneMeter = new Tone.Meter({ channels: 2 });
      Tone.Destination.chain(toneMeter);
      for (let k in app.layers) {
        await app.makeChannel(app.layers[k].l + "-" + app.layers[k].v, 0);
      }
      setTimeout(function () {
        Tone.Transport.start();
        app.isPlaying = true;
      }, 1000);
    },
    stop() {
      Tone.Transport.stop();
      this.isPlaying = false;
    },
    async mintSeed(){
      const app = this
      app.isMinting = true
        try {
          let minted = await app.contract.methods
            .mintTrack(app.seed)
            .send({ from: app.account });
          alert("Successfully minted at: " + minted.transactionHash);
          app.isMinting = false
        } catch (e) {
          alert(e);
        }
    }
  },
};
</script>
