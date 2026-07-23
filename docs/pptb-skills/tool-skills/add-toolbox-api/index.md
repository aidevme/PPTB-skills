---
title: add-toolbox-api
description: Wires up window.toolboxAPI calls for connections, utils, terminal, invocation, and tool context into a tool's code.
last_verified: 2026-07-22
---

# add-toolbox-api

This skill automates adding `window.toolboxAPI` calls to a PPTB tool — the platform-level API almost every tool reaches for first, since Dataverse and Power Platform calls need to know which connection to use. A developer reaches for it whenever the tool needs to read the active connection, show a notification, manage a terminal session, or launch/receive data from another tool.

**Every ToolBox API call this skill generates is `await`ed, and any call scoped to a specific connection includes an explicit `connectionTarget: 'primary' | 'secondary'` argument whenever the tool supports a secondary connection — the parameter defaults to `'primary'` but multi-connection tools must not rely on the default when secondary access is intended.**

## When to use it

- "Get the active Dataverse connection in my tool"
- "Show a notification when this operation finishes"
- "Copy this data to the clipboard"
- "Add support for a secondary connection"
- "Create a terminal session in my tool" / "run a build command from my tool"
- "Let this tool launch another tool and get a result back"
- "Read the launch context this tool was started with"
- "Open this record in the user's browser"

## Inputs

- Which capability the tool needs: connections, utils (notification/clipboard/theme/parallel/browser), terminal, invocation, or tool context
- Whether the tool needs `multiConnection` support (`"optional"` or `"required"`) — determines whether generated calls pass `connectionTarget`
- For invocation: the target tool's npm package name (`toolId`) and the shape of prefill/return data
- For terminal: working directory, environment variables, and whether the panel should be visible

## What it does

1. Adds `await toolboxAPI.connections.getActiveConnection()` (and `getSecondaryConnection()` when multi-connection is enabled) wherever the tool needs connection metadata (`Connection.name`, `.environment`, `.url`, `.enabledForPowerPlatformAPI`, `.scopesForPowerPlatformAPI`).
2. Wires `toolboxAPI.utils.showNotification({ title, body, type, duration })` around operation completion/failure points, using `type: 'info' | 'success' | 'warning' | 'error'`.
3. Adds `toolboxAPI.utils.copyToClipboard(text)`, `toolboxAPI.utils.getCurrentTheme()`, `toolboxAPI.utils.executeParallel(...)`, and `toolboxAPI.utils.openInConnectionBrowser(url, connectionTarget?)` calls as requested, keeping `openInConnectionBrowser` restricted to `https:`/`http:` URLs.
4. Wires terminal lifecycle calls — `toolboxAPI.terminal.create(options)`, `.execute(terminalId, command)`, `.setVisibility(terminalId, visible)`, `.list()`, `.close(terminalId)`.
5. For inter-tool workflows, adds `toolboxAPI.invocation.launchTool(targetToolId, prefillData?, options?)` on the caller side, and `toolboxAPI.invocation.getLaunchContext()` / `toolboxAPI.invocation.returnData(returnData)` on the launched-tool side.
6. Adds `toolboxAPI.getToolContext()` where the tool needs its `toolId`, `instanceId`, `connectionUrl`, or `secondaryConnectionUrl` without needing access tokens.
7. When a generated call requires `multiConnection`, adds or updates `features.multiConnection` in `package.json`, and sets `features.minAPI` to at least the highest **Requires vX.Y.Z** badge among the methods used (for example `1.2.0` for `getActiveConnection`/`getSecondaryConnection`, `1.2.2` for `openInConnectionBrowser`, `1.2.2-beta` for the invocation API).
8. Flags any use of the deprecated `saveFile()`/`selectPath()` utils and rewrites them against the File System API instead.

## Example

Before: a tool with no connection awareness.

After:

```typescript
const connection = await toolboxAPI.connections.getActiveConnection()

if (connection) {
  await toolboxAPI.utils.showNotification({
    title: 'Connected',
    body: `Using ${connection.name} (${connection.environment})`,
    type: 'info',
    duration: 3000,
  })
} else {
  await toolboxAPI.utils.showNotification({
    title: 'No connection',
    body: 'Select a connection to continue.',
    type: 'warning',
    duration: 0,
  })
}
```

`package.json` gains, if a secondary connection is used elsewhere in the tool:

```json
"features": {
  "multiConnection": "optional",
  "minAPI": "1.2.0"
}
```

## Checklist it enforces

- [ ] Every ToolBox API call is `await`ed and wrapped in error handling.
- [ ] Multi-connection tools declare `features.multiConnection` (`"optional"` or `"required"`) in `package.json`.
- [ ] Calls that need the secondary connection explicitly pass `'secondary'` as `connectionTarget`.
- [ ] `package.json`'s `features.minAPI` covers the highest **Requires vX.Y.Z** badge among the ToolBox API methods called.
- [ ] No remaining calls to the deprecated `saveFile()`/`selectPath()` utils — migrated to the File System API.

## Related

- [ToolBox API](/pptb-tools/tool-development/toolbox-api/) — the API reference this skill is built on
- Related skills: `../add-dataverse-api/`, `../add-inter-tool-invocation/`
