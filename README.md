# PowerShell Docs

An interactive directory of PowerShell scripts. Find a script, adjust parameters, and copy the result.

## Features

- 2,260+ scripts across 25 categories
- Interactive parameter editor on each script page
- Real-time code preview as you change values
- One-click copy to clipboard
- Local search across all scripts
- Dark mode support

## Tech Stack

- VitePress for the documentation site
- Vue 3 for interactive components
- JSON manifest for script metadata
- Dynamic route generation from script data

## Project Structure

```
docs/
  .vitepress/
    config.js          Site configuration and sidebar generation
    theme/
      index.js         Theme entry point
      Layout.vue       Custom layout with sidebar footer
      custom.css       Style overrides
      components/
        Playground.vue  Interactive script editor
        HomeDemo.vue    Animated home page demo
        HomeFeatures.vue Category grid and CTA
  index.md              Home page
  guide.md              Getting started guide
  scripts/
    [script].md         Dynamic script page template
    [script].paths.js   Route generation from manifest
src/
  data/
    manifest.json       All script metadata and source code
scripts/
  parse-commands.js     Generates manifest from source scripts
```

## Development

```bash
npm install
npm run dev
```

The dev server runs at `http://localhost:5173`. The manifest regenerates automatically before each build.

## Build

```bash
npm run build
npm run preview
```

Output goes to `docs/.vitepress/dist/`.

## Manifest Generation

The manifest is built from source PowerShell scripts:

```bash
npm run generate-manifest
```

This parses all `.ps1` files and produces `src/data/manifest.json` with name, description, category, parameters, and raw code for each script.

## Adding Scripts

1. Place `.ps1` files in the source directory
2. Run `npm run generate-manifest`
3. The sidebar and pages update automatically

## License

MIT
