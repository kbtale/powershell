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
    ],
    search: {
      provider: 'local'
    }
  },
  
  // generate dynamic metadata and aeo structured data
  async transformPageData(pageData) {
    const params = pageData.params
    if (params) {
      const title = params.title
      const description = params.description
      
      pageData.frontmatter.title = title
      pageData.frontmatter.description = description
      
      const schema = {
        "@context": "https://schema.org",
        "@type": "SoftwareSourceCode",
        "name": title,
        "description": description,
        "programmingLanguage": "PowerShell",
        "codeRepository": "https://github.com/kbtale/powershell"
      }

      pageData.frontmatter.head = [
        ['meta', { name: 'description', content: description }],
        ['meta', { property: 'og:title', content: title }],
        ['meta', { property: 'og:description', content: description }],
        ['script', { type: 'application/ld+json' }, JSON.stringify(schema)]
      ]
    }
  }
})
