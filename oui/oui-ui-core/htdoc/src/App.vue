<template>
  <n-config-provider :theme="theme" :locale="locale" :date-locale="dateLocale" inline-theme-disabled>
    <router-view/>
  </n-config-provider>
</template>

<script setup>
import { theme, locale, dateLocale } from './naive-ui'
</script>
