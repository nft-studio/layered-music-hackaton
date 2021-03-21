<template>
  <div class="container" style="padding: 5vh 10%; font-size: 22px">
    <div style="height: 120px">
      <a href="/"><img
        src="/img/layered-music-logo.png"
        style="height: 100px;"
      /></a>
    </div>
    <hr />
    <div class="row" style="padding-top: 15px">
      <div class="columns">
        <div class="column">
          <div id="grid" style="padding: 20px">
            <Grid
              style="margin: 30px 0"
              :isPlaying="isPlaying"
              :layers="layers"
            />
          </div>
          <div v-if="seed">
            <span v-if="!isGenerating">Sequence you want to play:</span><br />
            <div style="font-size: 12px">{{ seed }}</div>
          </div>
          <br />
          <div v-if="isGenerating">Generating track, please wait..</div>
          <b-button v-if="!isPlaying && !isLoadingTracks" v-on:click="playSeed"
            >Play seed!</b-button
          >
          <b-button v-if="isPlaying" v-on:click="stop">Stop seed!</b-button>
          <div v-if="isMinting">Minting..please wait</div>
          <div v-if="isLoadingTracks">
            Loading genesis tracks, please wait...
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import Grid from "@/components/Grid.vue";
const axios = require("axios");
var Web3 = require("web3");
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
      imagegrid: "",
      contract: {},
      howMuchBuy: 1,
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
      activeTab: 0,
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
  async mounted() {
    const app = this;
    app.seed = app.$route.params.sequence;
    let seed = app.seed.replace("0x", "");
    let layers = [];
    for (let k = 0; k <= 5; k++) {
      let track = k + 1;
      let variant = parseInt(seed[k]);
      layers.push({ l: track, v: variant });
    }
    app.layers = layers;
  },
  methods: {
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
  },
};
</script>
