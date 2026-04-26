import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const COMMANDS_DIR = path.resolve(__dirname, '../commands');
const OUTPUT_FILE = path.resolve(__dirname, '../src/data/manifest.json');

/**
 * finds all .ps1 files in the ps directory.
 */
async function getPs1Files(dir) {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    const files = await Promise.all(entries.map((res) => {
        const resPath = path.resolve(dir, res.name);
        return res.isDirectory() ? getPs1Files(resPath) : resPath;
    }));
    return Array.prototype.concat(...files).filter(f => f.endsWith('.ps1'));
}

async function main() {
    console.log('Scanning for PowerShell commands...');
    
    try {
        const files = await getPs1Files(COMMANDS_DIR);
        console.log(`Found ${files.length} scripts:`, files.map(f => path.basename(f)));
        
    } catch (err) {
        console.error('Parser Error:', err);
        process.exit(1);
    }
}

main();
