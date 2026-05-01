import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PS_SCRIPTS_DIR = path.resolve(__dirname, '../ps-scripts');
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
        const regex = new RegExp(`\\.${tag}\\r?\\n\\s*([\\s\\S]*?)(?=\\r?\\n\\s*\\.|$)`, 'i');
        const match = cbh.match(regex);
        return match ? match[1].trim() : '';
    };

    // extract param() block using bracket-depth tracking
    let paramBlock = '';
    const paramStart = content.search(/\bparam\s*\(/i);
    if (paramStart !== -1) {
        const openParen = content.indexOf('(', paramStart);
        let depth = 1;
        let i = openParen + 1;
        while (i < content.length && depth > 0) {
            if (content[i] === '(') depth++;
            if (content[i] === ')') depth--;
            i++;
        }
        paramBlock = content.slice(openParen + 1, i - 1);
    }
    const params = [];

    paramBlock = paramBlock.replace(/\[\s*(?:Parameter|Validate\w*|CmdletBinding|Alias)\s*\([^\]]*\)\s*\]/gi, '');

    // regex for: [type]$Name = "Default"
    const paramRegex = /(?:\[([\w\.]+)\])?\s*\$(\w+)(?:\s*=\s*(['"]?)(.*?)\3)?/g;
    let match;
    while ((match = paramRegex.exec(paramBlock)) !== null) {
        const [_, type, name, quote, defaultValue] = match;
        
        // Safety check to ignore stray booleans if they somehow survived the strip
        if (name.toLowerCase() === 'true' || name.toLowerCase() === 'false') continue;
        params.push({
            name,
            type: type || 'string',
            defaultValue: defaultValue || '',
            description: extractTag(`PARAMETER ${name}`)
        });
    }

    // extract #Requires statements
    const requiresRegex = /^#Requires\s+(.*)$/gim;
    const requirements = [];
    let reqMatch;
    while ((reqMatch = requiresRegex.exec(content)) !== null) {
        requirements.push(reqMatch[1].trim());
    }

    const cleanText = (text) => text.replace(/\s+/g, ' ').trim();

    return {
        id: path.basename(filePath, '.ps1'),
        name: path.basename(filePath, '.ps1'),
        description: cleanText(extractTag('SYNOPSIS')) || cleanText(extractTag('DESCRIPTION')),
        category: extractTag('CATEGORY') || path.dirname(filePath).split(path.sep).pop(),
        requirements: requirements,
        parameters: params,
        path: filePath,
        rawCode: content.replace(/<#[\s\S]*?#>\s*/, '').trim()
    };
}

async function main() {
    console.log('Scanning for PowerShell scripts...');
    
    try {
        const files = await getPs1Files(PS_SCRIPTS_DIR);
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
