<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps(['title', 'description', 'code', 'params'])

// parse params string into reactive object
const variables = ref({})
const parsedParams = computed(() => {
  try {
    return JSON.parse(props.params || '[]')
  } catch (e) {
    return []
  }
})

onMounted(() => {
  parsedParams.value.forEach(param => {
    variables.value[param.name] = param.defaultValue
  })
})

const generatedCode = computed(() => {
  let result = props.code || '';
  
  parsedParams.value.forEach(param => {
    const value = variables.value[param.name];
    
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
  <div class="playground-container">
    <div class="header">
      <h1 class="title">{{ title }}</h1>
      <p class="description">{{ description }}</p>
    </div>

    <div class="panel-grid">
      <!-- customize panel -->
      <div class="panel customize-panel">
        <h2 class="panel-title">Customize</h2>
        <div class="controls">
          <div v-for="param in parsedParams" :key="param.name" class="control-group">
            <label :for="param.name" class="label">
              {{ param.name }}
              <span class="type">[{{ param.type }}]</span>
            </label>

            <!-- specialized inputs based on type -->
            <div v-if="param.type.toLowerCase() === 'switch'" class="toggle-container">
              <input 
                type="checkbox"
                :id="param.name"
                v-model="variables[param.name]"
                class="checkbox"
              />
              <span class="toggle-label">{{ variables[param.name] ? 'Enabled' : 'Disabled' }}</span>
            </div>

            <input 
              v-else-if="['int', 'long', 'decimal', 'double'].includes(param.type.toLowerCase())"
              type="number"
              :id="param.name"
              v-model.number="variables[param.name]"
              class="input-field"
            />

            <input 
              v-else
              type="text"
              :id="param.name"
              v-model="variables[param.name]"
              class="input-field"
              :placeholder="param.defaultValue"
            />

            <p v-if="param.description" class="help-text">{{ param.description }}</p>
          </div>
        </div>
      </div>

      <!-- code panel -->
      <div class="panel code-panel">
        <div class="code-header">
          <h2 class="panel-title">Command</h2>
          <button 
            @click="copyToClipboard" 
            class="copy-button"
            :class="{ 'is-copied': copied }"
          >
            {{ copied ? 'Copied!' : 'Copy' }}
          </button>
        </div>
        <div class="code-block">
          <pre><code>{{ generatedCode }}</code></pre>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.playground-container {
  margin-top: 2rem;
  animation: fade-in 0.5s ease-out;
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.title {
  font-size: 1.875rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  letter-spacing: -0.025em;
}

.description {
  color: var(--vp-c-text-2);
  margin-bottom: 2rem;
}

.panel-grid {
  display: grid;
  gap: 1.5rem;
}

@media (min-width: 1024px) {
  .panel-grid {
    grid-template-columns: 1fr 1fr;
  }
}

.panel {
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  padding: 1.5rem;
  background: var(--vp-c-bg-soft);
}

.panel-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 1.25rem;
}

.control-group {
  margin-bottom: 1rem;
}

.label {
  display: block;
  font-size: 0.875rem;
  font-weight: 500;
  margin-bottom: 0.5rem;
}

.type {
  font-family: var(--vp-font-family-mono);
  font-size: 0.75rem;
  color: var(--vp-c-brand);
  margin-left: 0.5rem;
}

.input-field {
  width: 100%;
  padding: 0.625rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg);
  font-size: 0.875rem;
  transition: border-color 0.2s;
}

.input-field:focus {
  border-color: var(--vp-c-brand);
  outline: none;
}

.toggle-container {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.checkbox {
  width: 1.25rem;
  height: 1.25rem;
  cursor: pointer;
}

.toggle-label {
  font-size: 0.875rem;
  color: var(--vp-c-text-1);
}

.help-text {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  margin-top: 0.25rem;
}

.code-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.code-block {
  background: var(--vp-code-block-bg);
  padding: 1rem;
  border-radius: 8px;
  overflow-x: auto;
}

.copy-button {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  transition: all 0.2s;
}

.copy-button:hover {
  border-color: var(--vp-c-brand);
  color: var(--vp-c-brand);
}

.copy-button.is-copied {
  border-color: #10b981;
  color: #10b981;
  background: #10b98110;
}
</style>
