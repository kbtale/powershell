import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const manifestPath = path.resolve(__dirname, '../../src/data/manifest.json')

export default {
  paths() {
    if (!fs.existsSync(manifestPath)) return []
    const commands = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'))
    
    return commands.map((cmd) => {
      return {
        params: { 
            script: cmd.id,
            title: cmd.name,
            description: cmd.description,
            code: cmd.rawCode,
            params: JSON.stringify(cmd.parameters)
        }
      }
    })
  }
}
