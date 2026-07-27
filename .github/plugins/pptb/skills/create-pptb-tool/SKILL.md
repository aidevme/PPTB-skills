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

| Option | Stack | Best for | Reference implementation |
| --- | --- | --- | --- |
| **HTML Sample** | Vanilla TypeScript, no framework, modern ES2022 | Lightweight tools, simple utilities, learning the API basics | <https://github.com/PowerPlatformToolBox/sample-tools/tree/main/new/html-sample> |
| **React Sample** | React 18, TypeScript, Vite, HMR | Complex interactive tools, data visualization, tools needing a rich UI | <https://github.com/PowerPlatformToolBox/sample-tools/tree/main/new/react-sample> |
| **Vue Sample** | Vue 3 Composition API, `<script setup>`, TypeScript, Vite | Progressive web apps, form-heavy tools, tools needing two-way data binding | <https://github.com/PowerPlatformToolBox/sample-tools/tree/main/new/vue-sample> |
| **Svelte Sample** | Svelte 5, TypeScript, Vite, no virtual DOM | Performance-critical tools, embedded tools, tools with limited screen space | <https://github.com/PowerPlatformToolBox/sample-tools/tree/main/new/svelte-sample> |

If the developer already stated a framework directly (e.g. "build this with React"), skip the question and use their stated choice instead of asking.

Carry the chosen framework into Step 2 — it must match the framework selected there and in the generator's own prompt, so the scaffold and the reference sample stay consistent.

## Step 2: Scaffold the project

Ask the user for a tool name (if not already given), then run the Yeoman generator:

```bash
npx --package yo --package generator-pptb -- yo pptb <tool-name>
```

If the user has the generator installed globally already (`npm install -g yo generator-pptb`), `yo pptb <tool-name>` is equivalent — check with `npm list -g generator-pptb` before deciding which form to run.

Follow the generator's prompts, selecting the framework chosen in Step 1 when it asks. For the HTML option it produces a flat structure:

```text
my-tool/
├── package.json
├── index.html
├── styles.css
├── app.ts
└── README.md
```

For React, Vue, or Svelte it nests source files under `src/`, with a framework-specific subfolder for shared logic:

```text
my-tool/
├── package.json
├── index.html
├── vite.config.ts
├── src/
│   ├── main.tsx | main.ts        # entry point
│   ├── components/               # UI components (React/Vue/Svelte)
│   ├── hooks/                    # custom hooks (React only)
│   ├── composables/              # composables (Vue only)
│   └── lib/                      # utilities/stores (Svelte only)
└── README.md
```

**PPTB-specific Vite requirement:** the generator's `vite.config.ts` for React/Vue/Svelte builds to a single **IIFE bundle**, not the ES-module output Vite defaults to — PPTB loads tools inside a sandboxed `file://` iframe, which can't resolve ES module imports or `crossorigin` script loading. The config must:

- Set the build output format to `iife` and inline all CSS into that one bundle (no separate chunks, no code-splitting).
- Strip the `type="module"` and `crossorigin` attributes the default Vite HTML plugin adds to the `<script>` tag.
- Move the `<script>` tag to the end of `<body>` so the IIFE runs after the DOM elements it targets already exist.

If the generator handles this already, don't touch `vite.config.ts`. Only reproduce this configuration yourself for a manual scaffold (see below) — copy it from the matching sample's `vite.config.ts` rather than writing it from scratch.

If `npx`/the generator is unavailable or the user explicitly wants a manual scaffold, create the same file layout by hand and continue with Steps 3–5 to fill it in — the manifest and starter code below are generator-independent. For a manual scaffold, point the user at the matching sample from Step 1's table as a working reference to copy patterns from — e.g. for React, <https://github.com/PowerPlatformToolBox/sample-tools/tree/main/new/react-sample> — and copy its `vite.config.ts` verbatim for the IIFE build requirement above, since getting that config wrong silently breaks loading the tool in the ToolBox host.

## Step 3: Write the manifest (`package.json`)

Required fields: `name` (unscoped, kebab-case, e.g. `pptb-my-tool`), `version`, `displayName`, `description`, `main` (entry point, usually `index.html`), `icon`, `license`, `contributors`, `configurations` (at least `repository`). See the `configure-csp` and `validate-pptb-tool` skills for the CSP-exceptions and validation pieces of the manifest — don't duplicate that logic here, just leave `cspExceptions` out unless the user already knows they need it.

Follow the naming convention used by the reference samples themselves — unscoped, kebab-case, no `@org/` prefix. Each reference implementation from Step 1 is named after this pattern (`pptb-<framework>-sample-tool`), so name the scaffolded tool the same way, swapping in the tool's own name instead of `sample-tool`:

| Framework chosen in Step 1 | Reference sample's own name | Suggested pattern for the new tool |
| --- | --- | --- |
| HTML | `pptb-standard-sample-tool` | `pptb-<tool-name>-tool` |
| React | `pptb-react-sample-tool` | `pptb-react-<tool-name>-tool` |
| Vue | `pptb-vue-sample-tool` | `pptb-vue-<tool-name>-tool` |
| Svelte | `pptb-svelte-sample-tool` | `pptb-svelte-<tool-name>-tool` |

For example, if the developer picked React in Step 1, this is the React sample's own manifest — adapt `name`, `description`, `contributors`, and `configurations` for the new tool, and add an `icon` (the sample omits one, but the host still expects the field):

```json
{
  "name": "pptb-react-sample-tool",
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
  "engines": {
    "node": ">=18.0.0"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@pptb/types": "^1.0.17",
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5.6.3",
    "vite": "^7.1.11"
  },
  "scripts": {
    "build": "tsc && vite build",
    "dev": "vite",
    "preview": "vite preview",
    "watch": "vite build --watch"
  }
}
```

As with the HTML sample above, don't copy its monorepo-only bits verbatim — the nested npm `repository` object pointing at `desktop-app.git`/`directory: sample/react-sample`, or `configurations.website`/`readmeUrl` pointing at the sample repo itself.

The HTML sample's own manifest shows the fuller shape a published tool grows into — `configurations.website`/`readmeUrl` for in-app docs links, and an `enabledForPowerPlatformAPI` feature flag alongside `multiConnection`:

```json
{
  "name": "pptb-standard-sample-tool",
  "version": "1.2.8",
  "displayName": "HTML Sample Tool",
  "description": "A sample Power Platform ToolBox tool built with HTML, CSS, and TypeScript",
  "main": "index.html",
  "icon": "icon/sample-icon.svg",
  "license": "GPL-3.0",
  "contributors": [{ "name": "Your Name" }],
  "configurations": {
    "repository": "https://github.com/your-org/my-tool",
    "website": "https://your-docs-site.example.com",
    "readmeUrl": "https://raw.githubusercontent.com/your-org/my-tool/main/README.md"
  },
  "features": {
    "minAPI": "1.2.2",
    "multiConnection": "optional",
    "enabledForPowerPlatformAPI": true
  },
  "keywords": ["powerplatform", "dataverse", "toolbox", "pptb", "sample", "html"]
}
```

Don't copy the sample's monorepo-only bits verbatim: its top-level npm `repository` object (`type`/`url`/`directory`) points at the `sample-tools` monorepo and its `files` array includes `npm-shrinkwrap.json`/`pptb.config.json` — neither applies to a standalone tool with its own repo.

For Svelte, this is the sample's own manifest — note it has no `configurations` block or `icon` at all (add both for a real tool), and needs `"type": "module"` alongside the Svelte 5 toolchain:

```json
{
  "name": "pptb-svelte-sample-tool",
  "version": "1.0.0",
  "type": "module",
  "displayName": "My Tool",
  "description": "Description of what your tool does",
  "main": "index.html",
  "icon": "icons/test.svg",
  "license": "MIT",
  "contributors": [{ "name": "Your Name" }],
  "configurations": {
    "repository": "https://github.com/your-org/my-tool"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "dependencies": {
    "svelte": "^5.14.9"
  },
  "devDependencies": {
    "@pptb/types": "^1.0.1",
    "@sveltejs/vite-plugin-svelte": "^4.0.3",
    "@tsconfig/svelte": "^5.0.4",
    "svelte-check": "^4.1.3",
    "typescript": "^5.6.3",
    "vite": "^5.4.11"
  },
  "scripts": {
    "build": "vite build",
    "dev": "vite",
    "preview": "vite preview",
    "check": "svelte-check --tsconfig ./tsconfig.json"
  }
}
```

As with the other samples, don't copy its monorepo-only `repository` object (`desktop-app.git`/`directory: sample/svelte-sample`) — point `configurations.repository` at the new tool's own repo instead. Also run the sample's `check` script (`svelte-check`) as part of validating a Svelte tool before publishing, alongside `pptb-validate`.

For Vue, this is the sample's own manifest — like Svelte, it has no `configurations` block or `icon` at all (add both for a real tool), and its build script runs `vue-tsc` (the Vue-aware type checker) ahead of `vite build`:

```json
{
  "name": "pptb-vue-sample-tool",
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
  "engines": {
    "node": ">=18.0.0"
  },
  "dependencies": {
    "vue": "^3.5.13"
  },
  "devDependencies": {
    "@pptb/types": "^1.0.17",
    "@vitejs/plugin-vue": "^5.2.1",
    "typescript": "^5.6.3",
    "vite": "^5.4.11",
    "vue-tsc": "^2.2.0"
  },
  "scripts": {
    "build": "vue-tsc && vite build",
    "dev": "vite",
    "preview": "vite preview"
  }
}
```

As with the other samples, don't copy its monorepo-only `repository` object (`desktop-app.git`/`directory: sample/vue-sample`) — point `configurations.repository` at the new tool's own repo instead.

- `iconURL` under `configurations` is **removed** — never emit it. Use the top-level `icon` field, a path relative to the `dist` root (e.g. `icons/test.svg`).
- `configurations.website` and `configurations.readmeUrl` are optional but recommended — they surface documentation links inside the ToolBox UI. `readmeUrl` must be a raw `githubusercontent.com` URL, not a GitHub blob/tree link.
- Make the icon theme-aware: set `fill="currentColor"` (or `stroke="currentColor"`) in the SVG so it adapts to the host's light/dark theme.
- Only set `features.minAPI` if the tool actually depends on an API version newer than the first public release — check each API's "Requires vX.Y.Z" badge in the reference docs and use the lowest version that covers everything the tool needs.
- Set `features.enabledForPowerPlatformAPI: true` only if the tool actually calls `powerplatformAPI` — see `add-powerplatform-api`.
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

### Try it in ToolBox

`npm run dev` gives HMR for React/Vue/Svelte, but `window.toolboxAPI`/`dataverseAPI`/`powerplatformAPI` only exist inside the ToolBox host's iframe — a bare browser tab against the dev server will show `undefined` for all three, and `getActiveConnection()` returns `null` until a connection is created in ToolBox. So dev mode is for UI iteration only; to actually exercise the host APIs:

1. `npm run build` (produces the IIFE bundle in `dist/`).
2. In Power Platform ToolBox, go to **Tools → Install Tool** and point it at the built `dist/` directory.
3. Confirm the connection info renders and the "Tool Loaded" notification fires — that's the signal the manifest, entry point, and API calls are wired correctly end to end.

The starter above only touches two `toolboxAPI` methods — see [`references/toolbox-api.md`](references/toolbox-api.md) for when to hand off to the `add-toolbox-api` skill for the rest of the surface (secondary connections, terminal sessions, inter-tool invocation, tool context).

## Step 6: Community and etiquette note

If the user is porting or rebuilding an existing **XrmToolBox** tool, tell them: reach out to the original author first if they aren't the author themselves — this is a courtesy expected in the community, not a legal requirement, and it keeps collaboration and credit intact. Mention the PPTB Discord community as the place to discuss tool development, share ideas, and get help — link it from the generated `README.md` if the user wants (verify the current invite URL against the project's own docs/README before sharing, since Discord invite links can expire or rotate).

## Next steps

Once the scaffold is in place, hand off to the sibling skills as needed:

- `add-toolbox-api` / `add-dataverse-api` / `add-powerplatform-api` — wire up the specific host APIs the tool needs
- `configure-csp` — if the tool needs to reach an external domain
- `add-error-handling` — retrofit try/catch and user-facing notifications around API calls
- `validate-pptb-tool` — run `pptb-validate` before publishing
- `publish-pptb-tool` — build, validate, and publish to npm + the ToolBox registry
