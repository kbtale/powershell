<script setup>
defineProps(['title', 'description', 'code', 'params'])
</script>

<template>
  <div class="playground">
    <p>Playground component for {{ title }}</p>
  </div>
</template>

<style scoped>
.playground {
  margin-top: 2rem;
  padding: 1rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
}
</style>
