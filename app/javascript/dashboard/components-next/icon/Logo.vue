<script setup>
import { useAttrs } from 'vue';

const attrs = useAttrs();
const sidebarLogoUrl = '/logo.svg';
</script>

<template>
  <img
    v-bind="attrs"
    :src="sidebarLogoUrl"
    class="rounded-lg"
  />
</template>
