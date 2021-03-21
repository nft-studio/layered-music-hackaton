<template>
  <div
    style="
      width: 100%;
      padding: 0 40px;
      background: #333;
      border-radius: 10px;
    "
  >
    <div class="row">
      <div class="columns">
        <div class="column" v-for="layer in layers" :key="layer.l">
          <div v-bind:class="{ layerActive: layer.v === 1 }" class="layer layer1"></div>
          <div v-bind:class="{ layerActive: layer.v === 2 }" class="layer layer2"></div>
          <div v-bind:class="{ layerActive: layer.v === 3 }" class="layer layer3"></div>
          <div v-bind:class="{ layerActive: layer.v === 4 }" class="layer layer4"></div>
          <div v-bind:class="{ layerActive: layer.v === 5 }" class="layer layer5"></div>
          <div v-bind:class="{ layerActive: layer.v === 6 }" class="layer layer6"></div>
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
    font-size:10px;
    line-height: 25px;
    margin:20px 0;
    color: #888;
  }
  .layer1.layerActive {
    background: rgb(12, 209, 94)!important;
    color: rgb(12, 209, 94)!important;
  }
  .layer2.layerActive {
    background: rgb(88, 12, 209)!important;
    color: rgb(88, 12, 209)!important;
  }
  .layer3.layerActive {
    background: rgb(209, 12, 55)!important;
    color: rgb(209, 12, 55)!important;
  }
  .layer4.layerActive {
    background: rgb(209, 180, 12)!important;
    color: rgb(209, 180, 12)!important;
  }
  .layer5.layerActive {
    background: rgb(12, 196, 209)!important;
    color: rgb(12, 196, 209)!important;
  }
  .layer6.layerActive {
    background: rgb(209, 12, 209)!important;
    color: rgb(209, 12, 209)!important;
  }
</style>

<script>
export default {
  name: "Grid",
  props: ["layers"],
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
