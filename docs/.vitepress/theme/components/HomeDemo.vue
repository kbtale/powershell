<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const DEMO_DURATION = 12000
const PHASE_DURATION = DEMO_DURATION / 6

const phase = ref(0)
let intervalId = null

onMounted(() => {
  intervalId = setInterval(() => {
    phase.value = (phase.value + 1) % 6
  }, PHASE_DURATION)
})

onUnmounted(() => {
  if (intervalId) clearInterval(intervalId)
})

const codeLines = [
  { text: 'Get-Service', highlight: false },
  { text: '  -ComputerName "localhost"', highlight: false },
  { text: '  -Name "*"', highlight: true },
]

const isTyping = computed(() => phase.value === 1 || phase.value === 2)
const isCopied = computed(() => phase.value === 4)

const paramName = computed(() => {
  if (phase.value >= 2) return 'Spooler'
  return ''
})

const paramNamePlaceholder = computed(() => {
  if (phase.value === 1) return 'Spooler'
  return 'Enter value...'
})
</script>

<template>
  <div class="home-demo">
    <div class="demo-card">
      <div class="demo-code">
        <div class="demo-code-header">
          <span class="demo-code-label">Get-Service</span>
          <button class="demo-copy-btn" :class="{ copied: isCopied }">
            <svg v-if="!isCopied" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            <span>{{ isCopied ? 'Copied' : 'Copy' }}</span>
          </button>
        </div>
        <pre class="demo-code-body"><code><span class="code-cmd">Get-Service</span>
  <span class="code-param">-ComputerName</span> <span class="code-val">"localhost"</span>
  <span class="code-param" :class="{ 'code-highlight': isTyping }">-Name</span> <span class="code-val" :class="{ 'code-highlight': isTyping }">"<span class="typed-value">{{ paramName }}</span><span v-if="phase === 1" class="code-cursor">|</span>"</span></code></pre>
      </div>
      <div class="demo-params">
        <div class="demo-param-item">
          <label class="demo-param-label">ComputerName <code>string</code></label>
          <input class="demo-param-input" value="localhost" disabled />
        </div>
        <div class="demo-param-item">
          <label class="demo-param-label">Name <code>string</code></label>
          <input
            class="demo-param-input"
            :class="{ 'demo-focused': phase === 1 || phase === 2 }"
            :placeholder="paramNamePlaceholder"
            :value="paramName"
            disabled
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-demo {
  padding: 0 24px 48px;
}

.demo-card {
  display: flex;
  gap: 16px;
  max-width: 720px;
  margin: 0 auto;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  overflow: hidden;
  background: var(--vp-c-bg-soft);
}

.demo-code {
  flex: 1;
  min-width: 0;
}

.demo-code-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border-bottom: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
}

.demo-code-label {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--vp-c-text-2);
}

.demo-copy-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 0.6875rem;
  font-weight: 500;
  padding: 3px 8px;
  border-radius: 5px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  cursor: default;
  transition: color 0.2s, border-color 0.2s;
}

.demo-copy-btn.copied {
  color: #10b981;
  border-color: #10b981;
}

.demo-code-body {
  margin: 0;
  padding: 16px;
  font-size: 0.8125rem;
  line-height: 1.7;
  font-family: var(--vp-font-family-mono);
  background: var(--vp-code-block-bg);
  color: var(--vp-c-text-1);
  overflow-x: auto;
}

.code-cmd {
  color: var(--vp-c-brand-1);
  font-weight: 600;
}

.code-param {
  color: var(--vp-c-text-2);
}

.code-val {
  color: #a5d6ff;
}

.code-highlight {
  background: color-mix(in srgb, var(--vp-c-brand-1) 15%, transparent);
  border-radius: 2px;
  padding: 0 2px;
}

.code-cursor {
  animation: blink 0.6s step-end infinite;
}

@keyframes blink {
  50% { opacity: 0; }
}

.typed-value {
  color: #10b981;
  font-weight: 500;
}

.demo-params {
  width: 200px;
  flex-shrink: 0;
  padding: 16px 12px;
  border-left: 1px solid var(--vp-c-divider);
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.demo-param-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.demo-param-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.demo-param-label code {
  font-size: 0.625rem;
  font-weight: 400;
  padding: 1px 4px;
  border-radius: 3px;
  background: var(--vp-c-bg);
  color: var(--vp-c-brand-1);
}

.demo-param-input {
  width: 100%;
  padding: 5px 8px;
  font-size: 0.75rem;
  font-family: var(--vp-font-family-mono);
  border: 1px solid var(--vp-c-divider);
  border-radius: 5px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  outline: none;
}

.demo-param-input:disabled {
  opacity: 0.7;
}

.demo-focused {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 2px color-mix(in srgb, var(--vp-c-brand-1) 15%, transparent);
  opacity: 1 !important;
}

@media (max-width: 768px) {
  .home-demo {
    padding: 0 16px 32px;
  }

  .demo-card {
    flex-direction: column;
  }

  .demo-params {
    width: 100%;
    border-left: none;
    border-top: 1px solid var(--vp-c-divider);
    flex-direction: row;
    gap: 8px;
  }

  .demo-param-item {
    flex: 1;
  }
}
</style>
