<script setup>
import { useAttrs } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';

const attrs = useAttrs();
const globalConfig = useMapGetter('globalConfig/get');
const defaultLogoUrl = '/logo.svg';
</script>

<template>
  <img
    v-if="globalConfig.logoThumbnail"
    v-bind="attrs"
    :src="globalConfig.logoThumbnail"
    class="rounded-lg"
  />
  <img
    v-else
    v-bind="attrs"
    :src="defaultLogoUrl"
    class="rounded-lg"
  />
</template>
