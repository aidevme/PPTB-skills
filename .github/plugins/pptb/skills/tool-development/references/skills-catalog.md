# Tool development skills catalog

Full descriptions and trigger phrases for every skill `tool-development` routes to, grouped the same way as the "Which skill do I need?" table in `SKILL.md`. Use this when the compact table doesn't disambiguate a request — each entry below is copied verbatim from that skill's own frontmatter `description`.

## Scaffold

### `create-pptb-tool`

Scaffolds a new Power Platform ToolBox (PPTB) tool — runs the `yo pptb` generator (or falls back to a manual scaffold), writes a compliant `package.json` manifest, installs `@pptb/types`, and wires a minimal `index.html`/`app.ts` entry point against `toolboxAPI`. Use when starting a new PPTB tool from scratch, or asked to "create a PPTB tool", "scaffold a toolbox tool", "start a new tool project", "generate a PPTB tool".

## API Integration

### `add-toolbox-api`

Wires up `window.toolboxAPI` calls — connections (primary/secondary), utils (notifications, clipboard, theme, parallel execution, browser open), terminal sessions, inter-tool invocation, and tool context — into an existing PPTB tool's code. Use when asked to "get the active connection", "show a notification", "copy to clipboard", "get the current theme", "add a secondary connection", "create a terminal in my tool", "run a command from my tool", "launch another tool and get a result back", or "read the tool context".

### `add-dataverse-api`

Wires up `window.dataverseAPI` calls — CRUD, relationship associations, FetchXML/OData queries, entity/attribute/relationship/option-set metadata and schema writes, custom action/function execution, and solution deployment — into an existing PPTB tool's code. Use when asked to "create/retrieve/update/delete a Dataverse record", "run a FetchXML query", "run an OData query", "create a custom table with these columns", "add a choice/lookup field or relationship", "call this custom action/function", "deploy this solution zip", or "get metadata for this entity".

### `add-powerplatform-api`

Wires up `window.powerplatformAPI` namespace calls (environment management, governance, licensing, analytics, and the rest of the Power Platform REST surface) and the Entra app registration prerequisites they depend on. Use when asked to "call the Power Platform environment management API", "list environments/governance policies/licensing subscriptions from my tool", "check whether this connection is enabled for Power Platform API", "query analytics/app management/Copilot Studio/PowerApps/PowerAutomate/PowerPages from my tool", or when a `powerplatformAPI` call is failing/unauthorized.

### `add-file-system-api`

Wires up `toolboxAPI.fileSystem` calls — reading/writing text and binary files, checking existence, listing directories, and native save/select dialogs — into a PPTB tool's code. Use when asked to "read a config file in my tool", "let the user save/export a file", "let the user pick a file or folder", "list files in a directory", or "check if a file exists" from a PPTB tool.

### `add-events-api`

Wires up `toolboxAPI.events.on()` so a PPTB tool reacts to platform events — connection changes, settings updates, notifications, terminal activity, tool lifecycle — instead of polling. Use when asked to "react when the connection changes", "listen for settings updates", "run something when a terminal command finishes", "subscribe to tool lifecycle events", or "my tool needs to know when X happens without polling".

### `add-settings-api`

Wires up `toolboxAPI.settings` calls (`get`/`set`/`getAll`/`setAll`) so a PPTB tool persists user preferences across sessions — page size, theme, grid configuration. Use when asked to "save this preference for my tool", "persist the user's theme/page size/grid settings", "load saved settings on startup", or "store this configuration across sessions" for a PPTB tool.

## Configuration

### `configure-csp`

Adds and scopes `cspExceptions` entries in a PPTB tool's `package.json` manifest for external domains the tool needs to reach — CDN scripts, external APIs, webfonts, embedded frames. Use when asked to "add a CSP exception", "let my tool call this external API", "load this library from a CDN", "my tool shows a CSP violation in the console", or "configure Content Security Policy" for a tool.

## Hardening

### `add-error-handling`

Wraps a PPTB tool's `toolboxAPI`/`dataverseAPI`/`powerplatformAPI`/file-system calls in `try`/`catch`, adds contextual logging, user-facing notifications, and retry logic for transient failures. Use when asked to "add error handling to this tool", "wrap my Dataverse calls in try/catch", "this tool crashes silently when a call fails", "add retry logic for throttled requests", or as a pre-publish hardening pass after `create-pptb-tool` and before `validate-pptb-tool`/`publish-pptb-tool`.

## Extensibility

### `add-inter-tool-invocation`

Wires up a PPTB tool as a caller, a callee, or both, so it can launch another installed tool and exchange data with it — the `pptb.config.json` invocation contract plus the `toolboxAPI.invocation.launchTool()`/`getLaunchContext()`/`returnData()` calls. Use when asked to "let this tool launch the entity picker and get the selected record back", "make my tool discoverable as a FetchXML builder", "add an invocation contract to pptb.config.json", or "my tool needs to reuse another installed tool's picker instead of building its own".

### `add-agent-integration`

Exposes a PPTB tool to AI assistants through the ToolBox's built-in MCP server — declaring the `agents` object in `pptb.config.json`, choosing interactive vs. automated execution, and adding a headless `invokeHeadless(input, context)` entry point. Use when asked to "make this tool available to AI assistants", "expose my tool via MCP", "add headless/automated execution to my tool", "let an agent invoke this tool without opening the UI", or "why isn't my tool showing up for MCP discovery".

## Release

### `validate-pptb-tool`

Runs and interprets `pptb-validate` against a PPTB tool's `package.json` manifest before publishing. Use when asked to "validate my PPTB tool", "run pptb-validate", "check my manifest before publishing", "why is my tool failing review", or as the step right before `publish-pptb-tool`.

### `publish-pptb-tool`

Finalizes, builds, and publishes a PPTB tool to npm, then submits it to the ToolBox registry. Use when asked to "publish my tool", "release my PPTB tool", "submit my tool to the registry", "how do I publish to npm and ToolBox", or when a tool has passed local validation and is ready to ship.
