<template>
  <div
    style="
      width: 100%;
      margin: 30px 0;
      padding: 0 40px;
      background: #333;
      border-radius: 10px;
    "
  >
    <div class="row">
      <div class="columns">
        <div class="column" v-for="layer in layers" :key="layer.l">
          <div v-bind:class="{ layerActive: layer.v === 1 }" class="layer">Track {{ layer.l }} v1</div>
          <div v-bind:class="{ layerActive: layer.v === 2 }" class="layer">Track {{ layer.l }} v2</div>
          <div v-bind:class="{ layerActive: layer.v === 3 }" class="layer">Track {{ layer.l }} v3</div>
          <div v-bind:class="{ layerActive: layer.v === 4 }" class="layer">Track {{ layer.l }} v4</div>
          <div v-bind:class="{ layerActive: layer.v === 5 }" class="layer">Track {{ layer.l }} v5</div>
          <div v-bind:class="{ layerActive: layer.v === 6 }" class="layer">Track {{ layer.l }} v6</div>
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
  .layerActive {
    background: rgb(12, 209, 94)!important;
    color: rgb(12, 209, 94)!important;
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
