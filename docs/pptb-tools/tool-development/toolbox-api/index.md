---
title: ToolBox API
description: The host API a PPTB tool uses to interact with the toolbox shell.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/toolbox-api
last_verified: 2026-07-22
---

# ToolBox API

The ToolBox API (`window.toolboxAPI`) provides access to platform features and utilities: the active Dataverse connection(s), notifications and clipboard access, terminal sessions, inter-tool invocation, and the current tool's runtime context. It's the API most tools reach for first, since almost everything else (Dataverse calls, Power Platform calls) needs to know which connection to use.

**Every ToolBox API method is asynchronous — always `await` the call — and most connection-scoped methods accept an optional `connectionTarget: 'primary' | 'secondary'` parameter that defaults to `'primary'`.**

For complete TypeScript definitions, install the `@pptb/types` package:

```bash
npm install --save-dev @pptb/types
```

> **Note:** In `@pptb/types`, `DataverseConnection` is deprecated and has been renamed to `Connection`. A `type DataverseConnection = Connection` alias is kept for backward compatibility.

## Connections

Get information about the active Dataverse connection(s).

### `toolboxAPI.connections.getActiveConnection()`

Requires v1.2.0

Returns the currently active connection, or `null` if none is selected.

```typescript
const connection = await toolboxAPI.connections.getActiveConnection()

if (connection) {
  console.log('Connected to:', connection.name)
  console.log('Environment:', connection.environment)
  console.log('URL:', connection.url)
} else {
  console.log('No active connection')
}
```

**Returns:** `Promise<Connection | null>`

```typescript
interface Connection {
  id: string // Unique identifier of the connection
  name: string // Friendly name of the connection
  url: string // Base URL of the Dataverse instance
  environment: 'Dev' | 'Test' | 'UAT' | 'Production' // Environment classification
  environmentColor?: string // Hex color code associated with the environment (added in 1.2.0)
  category?: string // Category label assigned to the connection (added in 1.2.0)
  categoryColor?: string // Hex color code for the category badge (added in 1.2.0)
  createdAt: string // ISO date string of when the connection was created
  lastUsedAt?: string // ISO date string of when the connection was last used
  enabledForPowerPlatformAPI?: boolean // True when this connection is enabled for Power Platform API usage
  scopesForPowerPlatformAPI?: string[] // Granted scopes for Power Platform API calls
  isActive?: boolean // @deprecated legacy field retained for backwards compatibility
}

// Deprecated compatibility alias
type DataverseConnection = Connection
```

Example values that may appear in `scopesForPowerPlatformAPI`:

```typescript
[
  'https://api.powerplatform.com/EnvironmentManagement.Environments.Read',
  'https://api.powerplatform.com/EnvironmentManagement.Groups.Read',
  'https://api.powerplatform.com/EnvironmentManagement.Groups.ReadWrite',
  'https://api.powerplatform.com/EnvironmentManagement.Settings.Read',
  'https://api.powerplatform.com/EnvironmentManagement.Settings.ReadWrite',
  'https://api.powerplatform.com/Governance.CrossTenantConnectionReports.Read',
  'https://api.powerplatform.com/Governance.CrossTenantConnectionReports.ReadWrite',
  'https://api.powerplatform.com/PowerApps.Apps.Play',
  'https://api.powerplatform.com/PowerApps.Apps.Read',
  'https://api.powerplatform.com/PowerAutomate.Flows.Read',
  'https://api.powerplatform.com/.default',
]
```

## Secondary connections

As a tool developer, you may require access to a second Dataverse connection — useful for copying data or configuration between environments. To enable this, declare it in `package.json`:

```json
{
  "name": "@toolname",
  "version": "0.1.10",
  "displayName": "My Awesome Tool",
  "description": "A Power Platform Tool Box tool to do awesome things",
  "main": "index.html",
  "icon": "icons/test.svg",
  "contributors": [
    { "name": "Awesome Developer" }
  ],
  "features": {
    "multiConnection": "required",
    "minAPI": "1.2.0"
  }
}
```

Use the top-level `icon` field for your SVG icon path (relative to the `dist` root, for example `icons/test.svg`). Set the SVG fill to `currentColor` so it adapts to dark/light theme. When the user opens your tool, they're presented with the option to connect to a primary and secondary environment.

### `toolboxAPI.connections.getSecondaryConnection()`

Requires v1.2.0

Returns the currently active secondary connection, or `null` if none is configured.

```typescript
const secondaryConnection = await toolboxAPI.connections.getSecondaryConnection()

if (secondaryConnection) {
  console.log('Connected to:', secondaryConnection.name)
  console.log('Environment:', secondaryConnection.environment)
  console.log('URL:', secondaryConnection.url)
} else {
  console.log('No active secondary connection')
}
```

**Returns:** `Promise<Connection | null>` (same `Connection` type as above)

When interacting with Dataverse and you want to use the secondary connection, pass `'secondary'` as the `connectionTarget` parameter. `connectionTarget` is optional and defaults to `'primary'`.

```typescript
// Example usage of dataverseAPI using secondary connection
const myTables = await dataverseAPI.getAllEntitiesMetadata(
  ['logicalName'],
  'secondary',
)
```

## Utils

Utility functions for notifications, clipboard, and more.

> **Breaking change:** `saveFile()` and `selectPath()` have been migrated to the File System API.

### `toolboxAPI.utils.showNotification(options)`

Requires v1.0.17

Display a notification to the user.

```typescript
await toolboxAPI.utils.showNotification({
  title: 'Success',
  body: 'Operation completed successfully',
  type: 'success', // 'info' | 'success' | 'warning' | 'error'
  duration: 3000, // Auto-dismiss after 3 seconds
})
```

**Parameters:**

- `options` — notification configuration object
- `type`: `'info' | 'success' | 'warning' | 'error'`
- `duration`: number in milliseconds (`0` = persistent)

### `toolboxAPI.utils.copyToClipboard(text)`

Requires v1.0.17

Copy text to the system clipboard.

```typescript
const data = JSON.stringify({ accounts: [], contacts: [] }, null, 2)
await toolboxAPI.utils.copyToClipboard(data)

await toolboxAPI.utils.showNotification({
  title: 'Copied',
  body: 'Data copied to clipboard',
  type: 'success',
})
```

### `toolboxAPI.utils.getCurrentTheme()`

Requires v1.0.17

Get the current application theme.

```typescript
const theme = await toolboxAPI.utils.getCurrentTheme()
document.body.classList.add(`theme-${theme}`)
```

**Returns:** `Promise<'light' | 'dark'>`

### `toolboxAPI.utils.executeParallel(...promises)`

Requires v1.0.17

Execute multiple async operations in parallel.

```typescript
const [account, contact, opportunities] = await toolboxAPI.utils.executeParallel(
  dataverseAPI.retrieve('account', accountId, ['name']),
  dataverseAPI.retrieve('contact', contactId, ['fullname']),
  dataverseAPI.fetchXmlQuery(opportunityFetchXml),
)

console.log('All data fetched:', account, contact, opportunities)
```

### `toolboxAPI.utils.openInConnectionBrowser(url, connectionTarget?)`

Requires v1.2.2

Open a URL in the external browser associated with the tool's active connection. When the connection has a browser profile configured (for example a specific Chrome or Edge profile), the URL opens in that browser and profile so the user is already authenticated. Falls back to the system default browser when no profile is configured. Only `https:` and `http:` URLs are allowed.

```typescript
// Open a record in the browser using the primary connection's browser profile
await toolboxAPI.utils.openInConnectionBrowser(
  'https://contoso.crm.dynamics.com/main.aspx?etn=account&id=guid-here&pagetype=entityrecord',
)

// Open a URL using the secondary connection's browser profile
await toolboxAPI.utils.openInConnectionBrowser(
  'https://contoso-dev.crm.dynamics.com/main.aspx?pagetype=entitylist&etn=account',
  'secondary',
)
```

**Parameters:**

- `url: string` — the URL to open (must use `https:` or `http:` protocol)
- `connectionTarget?: 'primary' | 'secondary'` — which connection's browser profile to use. Defaults to `'primary'`

**Returns:** `Promise<void>`

## Terminal

Create and manage terminal sessions that are context-aware to your tool.

### `toolboxAPI.terminal.create(options)`

Requires v1.0.17

Create a new terminal.

```typescript
const terminal = await toolboxAPI.terminal.create({
  name: 'Build Terminal',
  cwd: '/path/to/project',
  env: {
    NODE_ENV: 'production',
  },
})

console.log('Terminal created:', terminal.id)
```

### `toolboxAPI.terminal.execute(terminalId, command)`

Requires v1.0.17

Execute a command in a terminal.

```typescript
const result = await toolboxAPI.terminal.execute(terminal.id, 'npm install')

if (result.exitCode === 0) {
  console.log('Command completed successfully')
} else {
  console.error('Command failed:', result.error)
}
```

### `toolboxAPI.terminal.setVisibility(terminalId, visible)`

Requires v1.0.17

Show or hide a terminal's UI panel.

```typescript
await toolboxAPI.terminal.setVisibility(terminal.id, true)
```

### `toolboxAPI.terminal.list()`

Requires v1.0.17

List all terminals created by your tool.

```typescript
const terminals = await toolboxAPI.terminal.list()
console.log(`This tool has ${terminals.length} terminals`)
```

### `toolboxAPI.terminal.close(terminalId)`

Requires v1.0.17

Close a terminal.

```typescript
await toolboxAPI.terminal.close(terminal.id)
```

## Invocation API

The Invocation API enables inter-tool communication — one tool can launch another, pass prefill data, and receive a return value when the callee finishes.

### `toolboxAPI.invocation.launchTool(targetToolId, prefillData?, options?)`

Requires v1.2.2-beta

Launch another installed tool from within your tool and optionally pass prefill data. Returns a promise that resolves with the data the target tool sends back via `returnData()`, or `null` if the target tool closes without returning data.

```typescript
// Tool A: launch an entity-picker tool and wait for the result
const result = await toolboxAPI.invocation.launchTool(
  '@my-org/entity-picker',
  { entityName: 'account' },
)

if (result) {
  console.log('Selected ID:', result.selectedId)
  console.log('Selected name:', result.selectedName)
}
```

**Parameters:**

- `targetToolId: string` — npm package name (toolId) of the tool to launch
- `prefillData?: Record<string, unknown>` — data to pre-populate the target tool's state
- `options?: object` — optional connection overrides: `{ primaryConnectionId?, secondaryConnectionId? }`

**Returns:** `Promise<unknown>` — data returned by the target tool, or `null` if it closes without returning data

### `toolboxAPI.invocation.getLaunchContext()`

Requires v1.2.2-beta

Read the prefill data passed by the tool that launched this tool. Returns `null` if this tool wasn't launched via an inter-tool invocation.

```typescript
// Tool B: read the launch context on startup
const ctx = await toolboxAPI.invocation.getLaunchContext()

if (ctx) {
  console.log('Launched with entity:', ctx.entityName)
  // Pre-populate UI based on ctx...
}
```

**Returns:** `Promise<Record<string, unknown> | null>`

### `toolboxAPI.invocation.returnData(returnData)`

Requires v1.2.2-beta

Return data back to the tool that launched this tool. This resolves the promise returned by the caller's `launchTool()` call. If this tool wasn't launched by another tool, the call is a no-op.

```typescript
// Tool B: after the user makes a selection, return it to the caller
await toolboxAPI.invocation.returnData({
  selectedId: 'guid-here',
  selectedName: 'Contoso Ltd',
})
```

**Parameters:**

- `returnData: Record<string, unknown>` — data to pass back to the caller

**Returns:** `Promise<void>`

## Tool context

### `toolboxAPI.getToolContext()`

Requires v1.0.17

Returns the current tool context used by the framework.

```typescript
const context = await toolboxAPI.getToolContext()

console.log('Tool ID:', context.toolId)
console.log('Instance ID:', context.instanceId)
console.log('Primary URL:', context.connectionUrl)
console.log('Secondary URL:', context.secondaryConnectionUrl)
```

**Returns:** `Promise<ToolContext>`

```typescript
interface ToolContext {
  toolId: string | null
  instanceId?: string | null
  connectionUrl: string | null
  connectionId?: string | null
  secondaryConnectionUrl?: string | null
  secondaryConnectionId?: string | null
}
```

`ToolContext` intentionally does not contain access tokens. Use `dataverseAPI` for authenticated Dataverse operations.

## Checklist

- [ ] Every ToolBox API call is `await`ed and wrapped in error handling.
- [ ] Multi-connection tools declare `features.multiConnection` (`"optional"` or `"required"`) in `package.json`.
- [ ] Calls that need the secondary connection explicitly pass `'secondary'` as `connectionTarget`.
- [ ] `package.json` `features.minAPI` covers the highest **Requires vX.Y.Z** badge among the ToolBox API methods you call.
- [ ] Code that used the old `saveFile()`/`selectPath()` utils has migrated to the File System API.

## Related links

- [ToolBox API (source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/toolbox-api)
- [Overview](/pptb-tools/tool-development/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
- [Package Manifest](/pptb-tools/tool-development/package-manifest/)
- [Dataverse API](/pptb-tools/tool-development/dataverse-api/)
- [Events API](/pptb-tools/tool-development/events-api/)
