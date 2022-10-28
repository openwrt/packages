<template>
  <div class="container">
    <a v-for="s in sponsors" :href="s.url" target="_bank">
      <img v-if="s.logo" :src="s.logo" width="200"/>
      <span v-if="s.title">{{ s.title }}</span>
    </a>
  </div>
</template>

<script>
export default {
  props: {
    sponsors: Array
  }
}
</script>

<style scoped>
.container {
  margin: 20px auto;
}

.container a {
  margin-right: 20px;
}

.container span {
  font-size: 3em;
  color: #636363;
}
</style>
