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
      Please connect your Metamask wallet first with
      <span style="color: #f00">Rinkeby Network</span>,<br />window should be
      open automatically or click below button.<br /><br />
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
              <b-tab-item label="Buy minting tokens">
                <hr />
                <div>
                  You must pay 0.05 ETH (Rinkeby) for each track,<br />please
                  select how many tracks do you want to buy: <br /><br />
                  <b-numberinput
                    :min="1"
                    :max="buyMax"
                    v-model="howMuchBuy"
                  ></b-numberinput>
                  <br />
                  <b-button
                    v-if="!isBuying"
                    type="is-primary"
                    v-on:click="buyMintings"
                    >Buy {{ howMuchBuy }} tracks for
                    {{ (howMuchBuy * 0.05).toFixed(2) }} ETH</b-button
                  >
                  <div v-if="isBuying">Buying tracks..please wait.</div>
                </div>
              </b-tab-item>
              <b-tab-item label="Mint new track">
                <hr />
                <div style="text-align: center">
                  <div>
                    <div style="font-size: 32px">
                      You can mint {{ balanceMinting }}
                      <span v-if="balanceMinting > 1 || balanceMinting === 0"
                        >tracks</span
                      ><span v-if="balanceMinting === 1">track</span>.
                    </div>
                    {{ trackCounts }} were created yet out of 720 max tracks.<br />
                    <span style="font-size: 16px">
                      To mint a new track generate one first using "Generate
                      track" button, then click "Mint track" button on the right
                      to create the NFT!<br />You can see all the tracks
                      directly on
                      <a
                        href="https://testnets.opensea.io/collection/layered-music"
                        target="_blank"
                        >OpenSea</a
                      >.
                    </span>

                    <hr />
                    <br />

                    <b-button v-if="!isGenerating" v-on:click="generateSeed"
                      >Generate track</b-button
                    >
                    <div v-if="isGenerating" style="padding-bottom:6px;">
                      Generating track, please wait..
                    </div>
                    <div id="grid" style="padding: 20px">
                      <Grid
                        style="margin: 30px 0"
                        :isPlaying="isPlaying"
                        :layers="layers"
                      />
                    </div>
                    <div v-if="seed">
                      <span v-if="isGenerating"
                        >Generating random seeds from Smart Contract:</span
                      >
                      <span v-if="!isGenerating">Generated sequence:</span
                      ><br />
                      <div style="font-size: 12px">{{ seed }}</div>
                    </div>
                    <br />
                    <b-button
                      style="float: left"
                      v-if="
                        balanceMinting > 0 &&
                        seedFound &&
                        !isMinting &&
                        !wasMinted
                      "
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
                    <div v-if="isMinting">Minting..please wait</div>
                    <div v-if="isLoadingTracks">
                      Loading genesis tracks, please wait...
                    </div>
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
const html2canvas = require("html2canvas");
import Grid from "@/components/Grid.vue";
import Owned from "@/components/Owned.vue";
const axios = require("axios");
var Web3 = require("web3");
const ABI = require("../util/abi.json");
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
      imagegrid: "",
      contract: {},
      howMuchBuy: 1,
      buyMax: 720,
      seed: "",
      isBuying: false,
      collectionToMint: "0xJitzu",
      collections: ["0xJitzu"],
      balanceMinting: 0,
      isMinting: false,
      isGenerating: false,
      changed: 0,
      seedFound: false,
      isPlaying: false,
      isLoadingTracks: false,
      wasMinted: false,
      activeTab: 1,
      trackCounts: 0,
      channels: {},
      interval: "",
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
  watch: {
    howMuchBuy() {
      const app = this;
      if (app.howMuchBuy < 1) {
        app.howMuchBuy = 1;
      } else if (app.howMuchBuy > app.buyMax) {
        app.howMuchBuy = app.buyMax;
      }
    },
  },
  async mounted() {
    const app = this;
    await app.connect();
    await app.checkContractUserState();
    app.interval = setInterval(async function () {
      await app.connect();
      await app.checkContractUserState();
    }, 500);
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
        if (app.account !== "") {
          clearInterval(app.interval);
        }
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
          app.buyMax = 720 - parseInt(app.trackCounts);
        } catch (e) {
          alert(e);
        }
      }
    },
    async buyMintings() {
      const app = this;
      const ethAmount = (app.howMuchBuy * 0.05).toFixed(2);
      try {
        app.isBuying = true;
        await app.contract.methods.buyMinting().send({
          from: app.account,
          value: app.web3.utils.toWei(ethAmount, "ether"),
        });
        if (app.howMuchBuy === 1) {
          alert("You just bought 1 track");
        } else {
          alert("You just bought " + app.howMuchBuy + " tracks");
        }
        app.isBuying = false;
        app.howMuchBuy = 1;
        app.checkContractUserState();
      } catch (e) {
        app.isBuying = false;
        alert("Something went wrong!");
      }
    },
    async screenshot() {
      return new Promise(async (response) => {
        const app = this;
        window.scrollTo(0, 0);
        const dataurl = (
          await html2canvas(document.getElementById("grid"))
        ).toDataURL();
        app.imagegrid = dataurl;
        response(true)
      });
    },
    async generateSeed() {
      const app = this;
      app.seed = "";
      app.seedFound = false;
      app.isGenerating = true;
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
          if (retries % 12 === 0) {
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
            let sequence = "";
            for (let j in app.layers) {
              sequence += app.layers[j].v.toString();
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
              app.isGenerating = false;
              await app.screenshot();
              var bodyFormData = new FormData();
              bodyFormData.append("image", app.imagegrid);
              bodyFormData.append("sequence", app.seed);
              try {
                app.axios({
                  method: "post",
                  url: "https://layeredmusic.nftstud.io/api/generate.php",
                  data: bodyFormData,
                  headers: { "Content-Type": "multipart/form-data" },
                });
              } catch (e) {
                console.log(e);
              }
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
          url: "/layers/" + app.collectionToMint + "/layer" + track + ".mp3",
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
      app.isLoadingTracks = true;
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
      for (let k in app.channels) {
        app.channels[k].dispose();
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
        app.changed = new Date().getTime();
      } catch (e) {
        alert(JSON.stringify(e));
      }
    },
  },
};
</script>
