import { defineConfig } from 'vitepress'
import fs from 'fs'
import path from 'path'

// load manifest to build sidebar
const manifestPath = path.resolve(__dirname, '../../src/data/manifest.json')
let sidebarSteps = []

try {
  if (fs.existsSync(manifestPath)) {
    const commands = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'))
    
    const categories = [...new Set(commands.map(c => c.category))]
    
    sidebarSteps = categories.map(cat => ({
      text: cat,
      collapsed: false,
      items: commands
        .filter(c => c.category === cat)
        .map(c => ({
          text: c.name,
          link: `/scripts/${c.id}`
        }))
    }))
  }
} catch (e) {
  console.error('failed to load manifest for sidebar', e)
}

export default defineConfig({
  title: "PowerShell Docs",
  description: "An interactive directory of PowerShell commands.",
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide' }
    ],
    sidebar: sidebarSteps,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/kbtale/powershell' }
    ]
  },
  
  // generate dynamic metadata for search engines
  async transformPageData(pageData) {
    const params = pageData.params
    if (params) {
      pageData.frontmatter.title = params.title
      pageData.frontmatter.description = params.description
      
      // add custom head tags
      pageData.frontmatter.head = [
        ['meta', { name: 'description', content: params.description }],
        ['meta', { property: 'og:title', content: params.title }],
        ['meta', { property: 'og:description', content: params.description }]
      ]
    }
  }
})
