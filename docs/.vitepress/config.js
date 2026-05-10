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

    const categoryNames = {
      ActiveDirectory: 'Active Directory',
      DBSystems: 'Database Systems',
      FileManagement: 'File Management',
      MgmtGraph: 'Microsoft Graph',
      O365: 'Office 365',
      SecretManagement: 'Secret Management',
      TextArt: 'Text Art',
      UserManagement: 'User Management',
      WinPrintManagement: 'Windows Print Management'
    }

    sidebarSteps = categories.map(cat => ({
      text: categoryNames[cat] || cat,
      collapsed: true,
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
    aside: false,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/kbtale/powershell' }
    ],
    footer: {
      message: 'An interactive directory of PowerShell scripts.',
      copyright: 'MIT License'
    },
    editLink: {
      pattern: 'https://github.com/kbtale/powershell/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },
    lastUpdated: {
      text: 'Updated'
    },
    search: {
      provider: 'local',
      options: {
        detailedView: true,
        locales: {
          root: {
            translations: {
              button: {
                buttonText: 'Search scripts...',
                buttonAriaLabel: 'Search scripts'
              }
            }
          }
        }
      }
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
