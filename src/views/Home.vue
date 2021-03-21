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
                    <div style="font-size: 32px">
                      You can mint {{ balanceMinting }}
                      <span v-if="balanceMinting > 1">tracks</span
                      ><span v-if="balanceMinting === 1">track</span>.
                    </div>
                    {{ trackCounts }} were created yet out of 720 max tracks.<br />
                    <Grid style="margin:30px 0;" :layers="layers" />
                    <div v-if="seed">
                      Generated sequence:<br />
                      <div style="font-size: 12px">{{ seed }}</div>
                    </div>
                    <br />
                    <b-button style="float: left" v-on:click="generateSeed"
                      >Generate track</b-button
                    >
                    <b-button
                      style="float: right"
                      v-if="seedFound && !isMinting && !wasMinted"
                      v-on:click="mintSeed"
                      >Mint seed!</b-button
                    >
                    <b-button
                      style="float: right"
                      v-if="seedFound && !isPlaying && !isLoadingTracks"
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
              <b-tab-item label="Your tracks">
                <hr />
                <Owned :changed="changed" />
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
import Owned from "@/components/Owned.vue";
var Web3 = require("web3");
const ABI = require("../util/abi.json");
const axios = require("axios");
import * as Tone from "tone";
export default {
  name: "Home",
  components: {
    Grid,
    Owned,
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
      balanceMinting: 0,
      isMinting: false,
      changed: 0,
      seedFound: false,
      isPlaying: false,
      isLoadingTracks: false,
      wasMinted: false,
      activeTab: 0,
      trackCounts: 0,
      channels: {},
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
      if (app.isPlaying) {
        app.stop();
      }
      let distributions = [0, 0, 0, 0, 0, 0];
      let retries = 0;
      let max = 1;
      let found = false;
      try {
        while (!found) {
          retries++;
          if (retries % 36 === 0) {
            console.log("Lowering difficulty.");
            if (max <= 6) {
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
            let sequence = ""
            for(let j in app.layers){
              sequence += app.layers[j].v.toString()
            }
            let owned = await app.contract.methods
              .ownerTrack(sequence)
              .call({ from: app.account });
            if (owned !== "0x0000000000000000000000000000000000000000") {
              found = false;
            } else {
              app.seed = "0x" + sequence;
              app.seedFound = true;
              app.wasMinted = false;
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
        app.channels[track] = new app.tone.Channel({
          pan,
        }).toDestination();
        const player = new app.tone.Player({
          url: "/layers/" + app.collectionToMint + "/layer" + track + ".wav",
          loop: true,
        })
          .sync()
          .start();
        player.connect(app.channels[track]);
        app.tone.loaded().then(() => {
          response(true);
        });
      });
    },
    async playSeed() {
      const app = this;
      await app.tone.start();
      app.isLoadingTracks = true
      const toneMeter = new app.tone.Meter({ channels: 2 });
      app.tone.Destination.chain(toneMeter);
      for (let k in app.layers) {
        await app.makeChannel(app.layers[k].l + "-" + app.layers[k].v, 0);
      }
      setTimeout(function () {
        app.tone.Transport.start();
        app.isPlaying = true;
        app.isLoadingTracks = false;
      }, 1000);
    },
    stop() {
      const app = this;
      app.tone.Transport.stop();
      for(let k in app.channels){
        app.channels[k].dispose()
      }
      this.isPlaying = false;
    },
    async mintSeed() {
      const app = this;
      app.isMinting = true;
      try {
        let minted = await app.contract.methods
          .mintTrack(app.seed)
          .send({ from: app.account });
        alert("Successfully minted at: " + minted.transactionHash);
        app.isMinting = false;
        app.wasMinted = true;
        app.checkContractUserState();
        app.changed = new Date().getTime()
      } catch (e) {
        alert(JSON.stringify(e));
      }
    },
  },
};
</script>
