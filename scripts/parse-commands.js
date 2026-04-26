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

async function parseFile(filePath) {
    const content = await fs.readFile(filePath, 'utf8');
    
    // comment-based help block
    const cbhMatch = content.match(/<#([\s\S]*?)#>/);
    const cbh = cbhMatch ? cbhMatch[1] : '';

    const extractTag = (tag) => {
        const regex = new RegExp(`\\.${tag}\\r?\\n\\s*([\\s\\S]*?)(?=\\n\\.|$)`, 'i');
        const match = cbh.match(regex);
        return match ? match[1].trim() : '';
    };

    // get parameters from param() block
    const paramMatch = content.match(/param\s*\(([\s\S]*?)\)/i);
    const paramBlock = paramMatch ? paramMatch[1] : '';
    const params = [];

    // regex for: [type]$Name = "Default"
    const paramRegex = /(?:\[(\w+)\])?\s*\$(\w+)(?:\s*=\s*(['"]?)(.*?)\3)?/g;
    let match;
    while ((match = paramRegex.exec(paramBlock)) !== null) {
        const [_, type, name, quote, defaultValue] = match;
        params.push({
            name,
            type: type || 'string',
            defaultValue: defaultValue || '',
            description: extractTag(`PARAMETER ${name}`)
        });
    }

    return {
        id: path.basename(filePath, '.ps1'),
        name: extractTag('SYNOPSIS') || path.basename(filePath, '.ps1'),
        description: extractTag('DESCRIPTION'),
        category: extractTag('CATEGORY') || path.dirname(filePath).split(path.sep).pop(),
        parameters: params,
        path: filePath,
        rawCode: content
    };
}

async function main() {
    console.log('Scanning for PowerShell commands...');
    
    try {
        const files = await getPs1Files(COMMANDS_DIR);
        const commands = await Promise.all(files.map(parseFile));
        
        const outputDir = path.dirname(OUTPUT_FILE);
        await fs.mkdir(outputDir, { recursive: true });

        await fs.writeFile(OUTPUT_FILE, JSON.stringify(commands, null, 2));

        console.log(`Found ${commands.length} scripts. Manifest generated at ${OUTPUT_FILE}`);
        
    } catch (err) {
        console.error('Parser Error:', err);
        process.exit(1);
    }
}

main();
