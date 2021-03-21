<template>
  <div>
    <div v-if="nftOwned.length > 0">
      <div v-for="sequence in nftOwned" style="width:45%; margin:0 2.5%; display:inline-block;" :key="sequence">
        Track {{ sequence }}
        <div class="tile" style="position:relative;">
          <div class="controls">
            <div
              class="control-button"
              v-if="(!isPlaying || whatPlaying !== sequence) && !isLoadingTracks"
              v-on:click="playSequence(sequence)"
              ><img src="/img/play.png"></div
            >
            <div
              class="control-button"
              v-if="whatPlaying === sequence && !isLoadingTracks"
              v-on:click="stop()"
              ><img src="/img/stop.png"></div
            >
          </div>
          <Grid :layers="layers[sequence]" />
        </div>
      </div>
    </div>
    <div v-if="nftOwned === 0">You have never minted any track.</div>
  </div>
</template>

<style scoped>
.controls{
  display: none;
  position: absolute;
  top:0; 
  left: 0;
  width:100%;
  background:rgba(0,0,0,0.3);
  height: 100%;
  border-radius: 10px;
}
.control-button{
  position: absolute;
  top:calc(50% - 15px);
  left: calc(50% - 15px);
  width:30px;
  height: 30px;
}
.control-button:hover{
  cursor: pointer;
}
.tile:hover .controls{
  display: block;
}
</style>

<script>
var Web3 = require("web3");
const ABI = require("../util/abi.json");
const axios = require("axios");
import * as Tone from "tone";
import Grid from "@/components/Grid.vue";
export default {
  components: { Grid },
  name: "Owned",
  props: ["changed"],
  data() {
    return {
      tone: Tone,
      axios: axios,
      web3: new Web3(window.ethereum),
      contractAddress: process.env.VUE_APP_SMART_CONTRACT_ADDRESS,
      account: "",
      seed: "",
      contract: {},
      nftOwned: [],
      layers: {},
      collectionToPlay: "0xJitzu",
      isPlaying: false,
      whatPlaying: "",
      isLoadingTracks: false,
      channels: {},
    };
  },
  watch: {
    async changed() {
      await this.connect();
      await this.checkContractUserState();
    },
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
          if (owned.length > 0) {
            let layers = {};
            for (let k in owned) {
              let seed = owned[k];
              seed = seed.replace("0x", "");
              let sublayers = [];
              for (let k = 0; k <= 5; k++) {
                let track = k + 1;
                let variant = parseInt(seed[k]);
                sublayers.push({ l: track, v: variant });
              }
              seed = "0x" + seed;
              layers[seed] = sublayers;
            }
            app.layers = layers;
            console.log(layers);
          }
        } catch (e) {
          alert(e);
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
          url: "/layers/" + app.collectionToPlay + "/layer" + track + ".wav",
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
    async playSequence(seed) {
      const app = this;
      await app.tone.start();
      app.stop();
      seed = seed.replace("0x", "");
      app.isLoadingTracks = true;
      const toneMeter = new app.tone.Meter({ channels: 2 });
      app.tone.Destination.chain(toneMeter);
      for (let k = 0; k <= 5; k++) {
        let track = k + 1;
        let variant = seed[k];
        await app.makeChannel(track + "-" + variant, 0);
      }
      setTimeout(function () {
        app.tone.Transport.start();
        app.isPlaying = true;
        app.whatPlaying = "0x" + seed;
        app.isLoadingTracks = false;
      }, 1000);
    },
    stop() {
      const app = this;
      app.whatPlaying = "";
      app.tone.Transport.stop();
      for (let k in app.channels) {
        app.channels[k].dispose();
      }
      this.isPlaying = false;
    },
  },
};
</script>
