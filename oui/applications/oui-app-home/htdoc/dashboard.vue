<template>
  <n-space vertical>
    <n-tooltip trigger="hover">
      <template #trigger>
        <n-progress type="dashboard" gap-position="bottom" :percentage="percentage" :color="color"/>
      </template>
      <slot></slot>
    </n-tooltip>
    <div style="text-align: center;">{{ label }}</div>
  </n-space>
</template>

<script>
export default {
  props: {
    label: String,
    percentage: Number,
    color: String
  }
}
</script>
