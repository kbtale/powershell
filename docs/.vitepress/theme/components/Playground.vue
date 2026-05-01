<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps(['title', 'description', 'code', 'params', 'requirements'])

// parse params string into reactive object
const variables = ref({})

const parsedParams = computed(() => {
  try {
    return JSON.parse(props.params || '[]')
  } catch (e) {
    return []
  }
})

const parsedRequirements = computed(() => {
  try {
    return JSON.parse(props.requirements || '[]')
  } catch (e) {
    return []
  }
})

// Initialize variables
onMounted(() => {
  parsedParams.value.forEach(param => {
    variables.value[param.name] = param.defaultValue
  })
})

const generatedCode = computed(() => {
  let result = props.code || '';
  
  parsedParams.value.forEach(param => {
    const value = variables.value[param.name];
    if (value === undefined || value === null) return;

    if (param.type.toLowerCase() === 'switch') {
      const switchRegex = new RegExp(`(\\s*)\\$${param.name}\\b`, 'g');
      result = result.replace(switchRegex, value ? '$1$' + param.name : '');
    } else {
      const valRegex = new RegExp(`(\\$${param.name}\\s*=\\s*)(['"]?)(.*?)\\2`, 'g');
      const formattedValue = typeof value === 'string' ? `${value}` : value;
      result = result.replace(valRegex, `$1$2${formattedValue}$2`);
    }
  });
  
  return result;
})

// handle clipboard copy
const copied = ref(false)
const copyToClipboard = async () => {
  try {
    await navigator.clipboard.writeText(generatedCode.value);
    copied.value = true;
    setTimeout(() => {
      copied.value = false;
    }, 2000);
  } catch (err) {
    console.error('failed to copy text:', err);
  }
}
</script>

<template>
  <div class="playground">
    <h1 class="playground-title">{{ title }}</h1>
    <p v-if="description" class="playground-desc">{{ description }}</p>

    <!-- prerequisites -->
    <section v-if="parsedRequirements.length > 0" class="req-section">
      <div class="section-bar">
        <span class="section-label">Prerequisites</span>
      </div>
      <div class="req-list">
        <div v-for="req in parsedRequirements" :key="req" class="req-pill">
          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
          {{ req }}
        </div>
      </div>
    </section>

    <!-- code block -->
    <section class="code-section">
      <div class="section-bar">
        <span class="section-label">Script</span>
        <button 
          @click="copyToClipboard" 
          class="copy-btn"
          :class="{ copied }"
        >
          <svg v-if="!copied" xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
          <span>{{ copied ? 'Copied' : 'Copy' }}</span>
        </button>
      </div>
      <pre class="code-pre"><code>{{ generatedCode }}</code></pre>
    </section>

    <!-- customize -->
    <section v-if="parsedParams.length > 0" class="customize-section">
      <div class="section-bar">
        <span class="section-label">Customize</span>
      </div>
      <div class="param-grid">
        <div v-for="param in parsedParams" :key="param.name" class="param-item">
          <label :for="param.name" class="param-label">
            {{ param.name }}
            <code class="param-type">{{ param.type }}</code>
          </label>

          <div v-if="param.type.toLowerCase() === 'switch'" class="switch-row">
            <button
              :id="param.name"
              class="switch-track"
              :class="{ active: variables[param.name] }"
              @click="variables[param.name] = !variables[param.name]"
              role="switch"
              :aria-checked="variables[param.name]"
            >
              <span class="switch-thumb" />
            </button>
            <span class="switch-state">{{ variables[param.name] ? 'On' : 'Off' }}</span>
          </div>

          <input 
            v-else-if="['int', 'long', 'decimal', 'double'].includes(param.type.toLowerCase())"
            type="number"
            :id="param.name"
            v-model.number="variables[param.name]"
            class="param-input"
          />

          <input 
            v-else
            type="text"
            :id="param.name"
            v-model="variables[param.name]"
            class="param-input"
            :placeholder="param.defaultValue || 'Enter value...'"
          />

          <p v-if="param.description" class="param-help">{{ param.description }}</p>
        </div>
      </div>
    </section>

    <section v-else class="customize-section">
      <div class="section-bar">
        <span class="section-label">Parameters</span>
      </div>
      <p class="empty-msg">This script has no configurable parameters.</p>
    </section>
  </div>
</template>

<style scoped>
.playground {
  animation: enter 0.4s ease-out;
}

@keyframes enter {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

/* -- header -- */
.playground-title {
  font-size: 2rem;
  font-weight: 700;
  letter-spacing: -0.03em;
  line-height: 1.2;
  margin-bottom: 0.5rem;
}

.playground-desc {
  color: var(--vp-c-text-2);
  font-size: 0.9375rem;
  line-height: 1.6;
  margin-bottom: 2rem;
}

/* -- shared section chrome -- */
.code-section,
.customize-section,
.req-section {
  border: 1px solid var(--vp-c-divider);
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 1.25rem;
}

.req-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  padding: 1rem;
}

.req-pill {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.75rem;
  font-weight: 500;
  padding: 0.375rem 0.75rem;
  border-radius: 20px;
  background: color-mix(in srgb, var(--vp-c-brand-1) 8%, var(--vp-c-bg-soft));
  color: var(--vp-c-brand-1);
  border: 1px solid color-mix(in srgb, var(--vp-c-brand-1) 20%, transparent);
}

.req-pill svg {
  flex-shrink: 0;
}

.section-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.625rem 1rem;
  border-bottom: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
}

.section-label {
  font-size: 0.8125rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--vp-c-text-2);
}

/* -- copy button -- */
.copy-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.75rem;
  font-weight: 500;
  padding: 0.25rem 0.625rem;
  border-radius: 6px;
  border: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  cursor: pointer;
  transition: color 0.2s, border-color 0.2s;
}

.copy-btn:hover {
  color: var(--vp-c-brand-1);
  border-color: var(--vp-c-brand-1);
}

.copy-btn.copied {
  color: #10b981;
  border-color: #10b981;
}

/* -- code block -- */
.code-pre {
  margin: 0;
  padding: 1.25rem 1rem;
  background: var(--vp-code-block-bg);
  font-size: 0.8125rem;
  line-height: 1.7;
  overflow-x: auto;
  color: var(--vp-c-text-1);
  outline: none;
  min-height: 100px;
}

/* -- customize section -- */
.param-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 1.25rem;
  padding: 1.25rem 1rem;
}

.param-item {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.param-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.8125rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.param-type {
  font-size: 0.6875rem;
  font-weight: 400;
  padding: 0.125rem 0.375rem;
  border-radius: 4px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-brand-1);
}

.param-input {
  width: 100%;
  padding: 0.5rem 0.75rem;
  font-size: 0.8125rem;
  font-family: var(--vp-font-family-mono);
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  transition: border-color 0.15s, box-shadow 0.15s;
}

.param-input:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 0 0 3px color-mix(in srgb, var(--vp-c-brand-1) 12%, transparent);
}

.param-input::placeholder {
  color: var(--vp-c-text-3);
}

/* -- switch toggle -- */
.switch-row {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.switch-track {
  position: relative;
  width: 36px;
  height: 20px;
  border-radius: 10px;
  border: none;
  background: var(--vp-c-divider);
  cursor: pointer;
  transition: background 0.2s;
  padding: 0;
}

.switch-track.active {
  background: var(--vp-c-brand-1);
}

.switch-thumb {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: white;
  transition: transform 0.2s;
}

.switch-track.active .switch-thumb {
  transform: translateX(16px);
}

.switch-state {
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

/* -- help text -- */
.param-help {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  line-height: 1.4;
  margin: 0;
}

.empty-msg {
  padding: 1.25rem 1rem;
  font-size: 0.8125rem;
  color: var(--vp-c-text-3);
  margin: 0;
}
</style>
