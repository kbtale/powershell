import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "PowerShell Docs",
  description: "Interactive PowerShell command documentation",
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide' }
    ],
    sidebar: [],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/kbtale/powershell' }
    ]
  }
})
