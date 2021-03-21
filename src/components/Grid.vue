<template>
  <div
    style="width: 100%; padding: 0 40px; background: #333; border-radius: 10px"
    v-bind:class="{ layerSmall: small }"
  >
    <div class="row">
      <div class="columns is-mobile" v-bind:class="{ layerSmall: small }">
        <div class="column is-2" v-for="layer in layers" :key="layer.l">
          <div
            :id="'layer-' + layer.l + '-1'"
            v-bind:class="{ layerActive: layer.v === 1 }"
            class="layer layer1"
          ></div>
          <div
            :id="'layer-' + layer.l + '-2'"
            v-bind:class="{ layerActive: layer.v === 2 }"
            class="layer layer2"
          ></div>
          <div
            :id="'layer-' + layer.l + '-3'"
            v-bind:class="{ layerActive: layer.v === 3 }"
            class="layer layer3"
          ></div>
          <div
            :id="'layer-' + layer.l + '-4'"
            v-bind:class="{ layerActive: layer.v === 4 }"
            class="layer layer4"
          ></div>
          <div
            :id="'layer-' + layer.l + '-5'"
            v-bind:class="{ layerActive: layer.v === 5 }"
            class="layer layer5"
          ></div>
          <div
            :id="'layer-' + layer.l + '-6'"
            v-bind:class="{ layerActive: layer.v === 6 }"
            class="layer layer6"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.layer {
  width: 100%;
  height: 25px;
  border-radius: 5px;
  background: #888;
  font-size: 10px;
  line-height: 25px;
  margin: 20px 0;
  color: #888;
}
.obscure {
  opacity: 0.1;
}
.layer1.layerActive {
  background: rgb(12, 209, 94) !important;
  color: rgb(12, 209, 94) !important;
}
.layer2.layerActive {
  background: rgb(88, 12, 209) !important;
  color: rgb(88, 12, 209) !important;
}
.layer3.layerActive {
  background: rgb(209, 12, 55) !important;
  color: rgb(209, 12, 55) !important;
}
.layer4.layerActive {
  background: rgb(209, 180, 12) !important;
  color: rgb(209, 180, 12) !important;
}
.layer5.layerActive {
  background: rgb(12, 196, 209) !important;
  color: rgb(12, 196, 209) !important;
}
.layer6.layerActive {
  background: rgb(209, 12, 209) !important;
  color: rgb(209, 12, 209) !important;
}
.layerSmall .column{
  margin: 5px 0!important;
  padding:0 5px!important;
}
.layerSmall{
  padding:5px 10px!important;
}
.layerSmall .layer{
  margin:10px 0!important;
}
</style>

<script>
export default {
  name: "Grid",
  props: ["layers", "isPlaying", "small"],
  data() {
    return {
      interval: "",
    };
  },
  watch: {
    isPlaying() {
      const app = this;
      if (app.isPlaying) {
        let isOscured = false;
        app.interval = setInterval(function () {
          if (!isOscured) {
            isOscured = true;
            for (let k in app.layers) {
              let element = document.getElementById(
                "layer-" + app.layers[k].l + "-" + app.layers[k].v
              );
              element.classList.add("obscure");
            }
          } else {
            isOscured = false;
            for (let k in app.layers) {
              let element = document.getElementById(
                "layer-" + app.layers[k].l + "-" + app.layers[k].v
              );
              element.classList.remove("obscure");
            }
          }
        }, 300);
      } else {
        clearInterval(app.interval);
      }
    },
  },
};
</script>
