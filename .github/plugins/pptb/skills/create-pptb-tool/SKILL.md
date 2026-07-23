---
name: create-pptb-tool
description: Scaffolds a new Power Platform ToolBox (PPTB) tool — runs the `yo pptb` generator (or falls back to a manual scaffold), writes a compliant `package.json` manifest, installs `@pptb/types`, and wires a minimal `index.html`/`app.ts` entry point against `toolboxAPI`. Use when starting a new PPTB tool from scratch, or asked to "create a PPTB tool", "scaffold a toolbox tool", "start a new tool project", "generate a PPTB tool".
---

# Create PPTB Tool

Power Platform ToolBox (PPTB) tools are web applications that run in a sandboxed iframe and talk to the host through namespaced, secure APIs (`window.toolboxAPI`, `window.dataverseAPI`, `window.powerplatformAPI`) over a structured `postMessage` protocol. This skill scaffolds a new tool project end to end: generator (or manual fallback) → manifest → type definitions → a working starter that calls the host.

**Do not write PPTB API calls directly in `index.html` — always through a bundled script (`app.ts`/`app.js`), and never assume the tool has a connection; every API call must handle the `null`/not-connected case.**

## Step 0: Detect existing setup

Before scaffolding, check whether the current directory is already a PPTB tool project:

- `package.json` exists and already has `displayName`, `main`, and `icon` fields
- `@pptb/types` is listed in `devDependencies`

**If both are true,** don't re-scaffold — tell the user this looks like an existing PPTB tool, and point them at the sibling skills (`add-toolbox-api`, `add-dataverse-api`, `add-powerplatform-api`, `configure-csp`, `validate-pptb-tool`, `publish-pptb-tool`) for further work instead.

**Otherwise,** proceed with Steps 1–6.

## Step 1: Ask what kind of tool to build

Before scaffolding anything, ask the developer which framework they want to build with. Use `AskUserQuestion` with these four options — they mirror the official sample tools repository (<https://github.com/PowerPlatformToolBox/sample-tools>), and each one has a complete reference implementation there:

| Option | Stack | Best for |
| --- | --- | --- |
| **HTML Sample** (`html-sample/`) | Vanilla TypeScript, no framework, modern ES2022 | Lightweight tools, simple utilities, learning the API basics |
| **React Sample** (`react-sample/`) | React 18, TypeScript, Vite, HMR | Complex interactive tools, data visualization, tools needing a rich UI |
| **Vue Sample** (`vue-sample/`) | Vue 3 Composition API, `<script setup>`, TypeScript, Vite | Progressive web apps, form-heavy tools, tools needing two-way data binding |
| **Svelte Sample** (`svelte-sample/`) | Svelte 5, TypeScript, Vite, no virtual DOM | Performance-critical tools, embedded tools, tools with limited screen space |

If the developer already stated a framework directly (e.g. "build this with React"), skip the question and use their stated choice instead of asking.

Carry the chosen framework into Step 2 — it must match the framework selected there and in the generator's own prompt, so the scaffold and the reference sample stay consistent.

## Step 2: Scaffold the project

Ask the user for a tool name (if not already given), then run the Yeoman generator:

```bash
npx --package yo --package generator-pptb -- yo pptb <tool-name>
```

If the user has the generator installed globally already (`npm install -g yo generator-pptb`), `yo pptb <tool-name>` is equivalent — check with `npm list -g generator-pptb` before deciding which form to run.

Follow the generator's prompts, selecting the framework chosen in Step 1 when it asks. It produces a structure along these lines:

```text
my-tool/
├── package.json
├── index.html
├── styles.css
├── app.ts
└── README.md
```

If `npx`/the generator is unavailable or the user explicitly wants a manual scaffold, create the same file layout by hand and continue with Steps 3–5 to fill it in — the manifest and starter code below are generator-independent. For a manual scaffold, point the user at the matching sample under the sample tools repository (<https://github.com/PowerPlatformToolBox/sample-tools>) — e.g. `react-sample/` — as a working reference to copy patterns from.

## Step 3: Write the manifest (`package.json`)

Required fields: `name` (scoped, e.g. `@org/tool-name`), `version`, `displayName`, `description`, `main` (entry point, usually `index.html`), `icon`, `license`, `contributors`, `configurations` (at least `repository`). See the `configure-csp` and `validate-pptb-tool` skills for the CSP-exceptions and validation pieces of the manifest — don't duplicate that logic here, just leave `cspExceptions` out unless the user already knows they need it.

```json
{
  "name": "@powerplatform/my-tool",
  "version": "1.0.0",
  "displayName": "My Tool",
  "description": "Description of what your tool does",
  "main": "index.html",
  "icon": "icons/test.svg",
  "license": "MIT",
  "contributors": [{ "name": "Your Name" }],
  "configurations": {
    "repository": "https://github.com/your-org/my-tool"
  },
  "features": {
    "minAPI": "1.2.0"
  },
  "keywords": ["powerplatform", "dataverse", "toolbox"]
}
```

- `iconURL` under `configurations` is **removed** — never emit it. Use the top-level `icon` field, a path relative to the `dist` root (e.g. `icons/test.svg`).
- Make the icon theme-aware: set `fill="currentColor"` (or `stroke="currentColor"`) in the SVG so it adapts to the host's light/dark theme.
- Only set `features.minAPI` if the tool actually depends on an API version newer than the first public release — check each API's "Requires vX.Y.Z" badge in the reference docs and use the lowest version that covers everything the tool needs.
- Ensure the icon file ends up in `dist/` at build time — via `shx` copy scripts, Vite's `public/` folder, or `copy-webpack-plugin`, depending on the generator's bundler choice.

## Step 4: Install type definitions

```bash
npm install --save-dev @pptb/types
```

This provides full TypeScript definitions for `toolboxAPI`, `dataverseAPI`, and `powerplatformAPI`. Note: `DataverseConnection` is deprecated in favor of `Connection` (a `DataverseConnection` alias remains for backward compatibility); the `Connection` type also includes `enabledForPowerPlatformAPI?: boolean` and `scopesForPowerPlatformAPI?: string[]`.

## Step 5: Implement the starter

`index.html` — keep it minimal; all API calls live in the bundled script, not inline:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Tool</title>
    <link rel="stylesheet" href="styles.css" />
  </head>
  <body>
    <div id="app">
      <h1>My Power Platform Tool</h1>
      <div id="connection-info"></div>
      <button id="test-btn">Test API</button>
      <div id="output"></div>
    </div>
    <script src="app.js"></script>
  </body>
</html>
```

`app.ts` — establish the connection check, an event subscription, and a startup notification; this is the pattern every subsequent API-wiring skill (`add-toolbox-api`, `add-dataverse-api`, `add-powerplatform-api`) builds on:

```typescript
/// <reference types="@pptb/types" />

async function initialize() {
  try {
    // Get active connection — always handle the null/not-connected case
    const connection = await toolboxAPI.connections.getActiveConnection()

    if (connection) {
      document.getElementById('connection-info')!.textContent =
        `Connected to: ${connection.name} (${connection.environment})`
    }

    // Subscribe to platform events once, during initialization
    toolboxAPI.events.on((event, payload) => {
      console.log('Event received:', payload.event, payload.data)

      if (payload.event === 'connection:updated') {
        initialize()
      }
    })

    // Confirm the tool loaded
    await toolboxAPI.utils.showNotification({
      title: 'Tool Loaded',
      body: 'My tool is ready!',
      type: 'success',
      duration: 3000,
    })
  } catch (error) {
    console.error('Initialization error:', error)
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initialize)
} else {
  initialize()
}
```

## Step 6: Community and etiquette note

If the user is porting or rebuilding an existing **XrmToolBox** tool, tell them: reach out to the original author first if they aren't the author themselves — this is a courtesy expected in the community, not a legal requirement, and it keeps collaboration and credit intact. Mention the PPTB Discord community as the place to discuss tool development, share ideas, and get help — link it from the generated `README.md` if the user wants (verify the current invite URL against the project's own docs/README before sharing, since Discord invite links can expire or rotate).

## Next steps

Once the scaffold is in place, hand off to the sibling skills as needed:

- `add-toolbox-api` / `add-dataverse-api` / `add-powerplatform-api` — wire up the specific host APIs the tool needs
- `configure-csp` — if the tool needs to reach an external domain
- `add-error-handling` — retrofit try/catch and user-facing notifications around API calls
- `validate-pptb-tool` — run `pptb-validate` before publishing
- `publish-pptb-tool` — build, validate, and publish to npm + the ToolBox registry
