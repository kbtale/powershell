<script setup>
import DefaultTheme from 'vitepress/theme'
const { Layout } = DefaultTheme
</script>

<template>
  <Layout>
    <template #sidebar-nav-after>
      <div class="sidebar-footer">
        <hr class="sidebar-footer-divider" />
        <a
          class="sidebar-footer-link"
          href="https://github.com/kbtale/powershell"
          target="_blank"
          rel="noopener"
        >
          <svg class="sidebar-footer-icon" viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0 0 24 12c0-6.63-5.37-12-12-12z"/>
          </svg>
          <span>kbtale/powershell</span>
        </a>
        <p class="sidebar-footer-copy">Powered by VitePress</p>
      </div>
    </template>
  </Layout>
</template>

<style>
.sidebar-footer {
  padding: 16px 0 0;
  font-size: 13px;
}

.sidebar-footer-divider {
  border: none;
  border-top: 1px solid var(--vp-c-divider);
  margin: 0 0 12px;
}

.sidebar-footer-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  color: var(--vp-c-text-2);
  font-weight: 500;
  text-decoration: none;
  transition: color 0.25s;
}

.sidebar-footer-link:hover {
  color: var(--vp-c-brand-1);
}

.sidebar-footer-icon {
  flex-shrink: 0;
  opacity: 0.7;
}

.sidebar-footer-copy {
  margin: 8px 0 0;
  color: var(--vp-c-text-3);
  font-size: 12px;
}
</style>
