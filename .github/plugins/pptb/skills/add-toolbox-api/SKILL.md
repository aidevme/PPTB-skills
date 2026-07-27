---
name: add-toolbox-api
description: Wires up `window.toolboxAPI` calls — connections (primary/secondary), utils (notifications, clipboard, theme, parallel execution, browser open), terminal sessions, inter-tool invocation, and tool context — into an existing PPTB tool's code. Use when asked to "get the active connection", "show a notification", "copy to clipboard", "get the current theme", "add a secondary connection", "create a terminal in my tool", "run a command from my tool", "launch another tool and get a result back", or "read the tool context".
---

# Add ToolBox API

The ToolBox API (`window.toolboxAPI`) is the platform-level API almost every PPTB tool reaches for first — it's how a tool learns which Dataverse connection is active, since `dataverseAPI` and `powerplatformAPI` calls both need that before they can do anything. This skill wires `toolboxAPI` calls into an existing tool's code across its five areas: connections, utils, terminal, invocation, and tool context.

**Every `toolboxAPI` call is asynchronous — always `await` it — and every connection-scoped method accepts an optional `connectionTarget: 'primary' | 'secondary'` that defaults to `'primary'`; a multi-connection tool must pass `'secondary'` explicitly wherever it means the secondary connection, never rely on the default.**

## Step 0: Prerequisites

- Confirm `@pptb/types` is in `devDependencies` (`npm install --save-dev @pptb/types` if not) — it provides the `Connection`, `ToolContext`, and method signatures this skill generates against.
- Note the type rename: `DataverseConnection` is deprecated in favor of `Connection` (a `DataverseConnection` alias remains for backward compatibility) — generate new code against `Connection`, and flag old `DataverseConnection` references for a rename if touching that file anyway.

## Step 1: Identify which capability is needed

Map the request to one (or more) of these areas before writing code:

| Area | Covers | Go to |
| --- | --- | --- |
| Connections | Active/secondary connection metadata | Step 2 |
| Utils | Notifications, clipboard, theme, parallel execution, opening URLs in the connection's browser | Step 3 |
| Terminal | Terminal session lifecycle | Step 4 |
| Invocation | Simple inter-tool launch/return without a discoverable capability contract | Step 5 |
| Tool context | The running tool's own IDs and connection URLs | Step 6 |

If the tool needs a fuller inter-tool contract — advertising capability tags in `pptb.config.json` so other tools can discover it via `findToolsByCapability()` — hand off to `add-inter-tool-invocation` instead of Step 5; this skill only covers the direct `launchTool()`/`getLaunchContext()`/`returnData()` calls.

## Step 2: Wire connections

`toolboxAPI.connections.getActiveConnection()` (Requires v1.2.0) returns `Promise<Connection | null>` — always handle the `null` case, since a tool can be opened before the user picks a connection:

```typescript
const connection = await toolboxAPI.connections.getActiveConnection()

if (connection) {
  console.log('Connected to:', connection.name, connection.environment)
} else {
  console.log('No active connection')
}
```

```typescript
interface Connection {
  id: string
  name: string
  url: string
  environment: 'Dev' | 'Test' | 'UAT' | 'Production'
  environmentColor?: string // added in 1.2.0
  category?: string // added in 1.2.0
  categoryColor?: string // added in 1.2.0
  createdAt: string
  lastUsedAt?: string
  enabledForPowerPlatformAPI?: boolean
  scopesForPowerPlatformAPI?: string[]
  isActive?: boolean // @deprecated
}
```

If the tool needs a second Dataverse connection (comparing/copying data across environments), add `toolboxAPI.connections.getSecondaryConnection()` (Requires v1.2.0, same `Connection | null` shape) and declare it in `package.json`:

```json
{
  "features": {
    "multiConnection": "required",
    "minAPI": "1.2.0"
  }
}
```

Use `"required"` when the tool cannot function without a secondary connection, `"optional"` when it enhances but isn't mandatory. Once declared, pass `'secondary'` explicitly to any `dataverseAPI`/`powerplatformAPI` call meant for that connection — `connectionTarget` defaults to `'primary'` and won't pick up the secondary connection on its own:

```typescript
const secondaryTables = await dataverseAPI.getAllEntitiesMetadata(['logicalName'], 'secondary')
```

## Step 3: Wire utils

> **Breaking change:** `saveFile()` and `selectPath()` are removed from `toolboxAPI.utils` — if the tool being edited still calls either, migrate it to the File System API (see that API's own docs) rather than adding new code against the old methods.

- **`toolboxAPI.utils.showNotification(options)`** (Requires v1.0.17) — `{ title, body, type: 'info' | 'success' | 'warning' | 'error', duration }`, where `duration` is milliseconds and `0` means persistent (no auto-dismiss). Wire this around operation completion/failure points.
- **`toolboxAPI.utils.copyToClipboard(text)`** (Requires v1.0.17) — copies a string; pair with a `showNotification` confirming the copy.
- **`toolboxAPI.utils.getCurrentTheme()`** (Requires v1.0.17) — returns `Promise<'light' | 'dark'>`; use it to apply a `theme-${theme}` class rather than hardcoding one theme.
- **`toolboxAPI.utils.executeParallel(...promises)`** (Requires v1.0.17) — runs multiple async calls (e.g. several `dataverseAPI` requests) concurrently and resolves with all results.
- **`toolboxAPI.utils.openInConnectionBrowser(url, connectionTarget?)`** (Requires v1.2.2) — opens `url` in the external browser/profile tied to the given connection, falling back to the system default browser when no profile is configured. **Only `https:`/`http:` URLs are allowed** — reject or strip anything else before calling it.

```typescript
await toolboxAPI.utils.showNotification({
  title: 'Success',
  body: 'Operation completed successfully',
  type: 'success',
  duration: 3000,
})

await toolboxAPI.utils.openInConnectionBrowser(
  'https://contoso.crm.dynamics.com/main.aspx?etn=account&id=guid-here&pagetype=entityrecord',
)
```

## Step 4: Wire terminal sessions

All terminal methods require v1.0.17 and are scoped to terminals the tool itself created:

```typescript
const terminal = await toolboxAPI.terminal.create({
  name: 'Build Terminal',
  cwd: '/path/to/project',
  env: { NODE_ENV: 'production' },
})

const result = await toolboxAPI.terminal.execute(terminal.id, 'npm install')
if (result.exitCode !== 0) {
  console.error('Command failed:', result.error)
}

await toolboxAPI.terminal.setVisibility(terminal.id, true)
const terminals = await toolboxAPI.terminal.list()
await toolboxAPI.terminal.close(terminal.id)
```

Check `result.exitCode` after every `execute()` call rather than assuming success — a non-zero exit code is not a thrown error, it's a normal return value.

## Step 5: Wire simple inter-tool invocation

These three methods (all Requires v1.2.2-beta) cover a direct launch/return without a discoverable capability contract — use `add-inter-tool-invocation` instead when the tool needs to advertise itself via `pptb.config.json` capability tags.

Caller side — `toolboxAPI.invocation.launchTool(targetToolId, prefillData?, options?)` resolves with whatever the target tool passes to `returnData()`, or `null` if it closes without returning anything:

```typescript
const result = await toolboxAPI.invocation.launchTool('@my-org/entity-picker', {
  entityName: 'account',
})

if (result) {
  console.log('Selected ID:', result.selectedId)
}
```

`options` accepts `{ primaryConnectionId?, secondaryConnectionId? }` to override which connections the launched tool opens with.

Callee side — read prefill data with `getLaunchContext()` (returns `null` if the tool wasn't launched via invocation) and send a result back with `returnData()`:

```typescript
const ctx = await toolboxAPI.invocation.getLaunchContext()
if (ctx) {
  // Pre-populate UI from ctx...
}

await toolboxAPI.invocation.returnData({ selectedId: 'guid-here', selectedName: 'Contoso Ltd' })
```

Always branch on a `null` result from `launchTool()` as "closed without data," not as an error condition.

## Step 6: Wire tool context

`toolboxAPI.getToolContext()` (Requires v1.0.17) returns the running tool's own identifiers and connection URLs — no access tokens, so it's safe to log or display, but it can't be used for authenticated calls (use `dataverseAPI` for that):

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

## Step 7: Reconcile `features.minAPI`

After wiring the calls the tool actually needs, set `package.json`'s `features.minAPI` to the highest **Requires vX.Y.Z** badge among them — for example `1.2.0` if the tool only uses `getActiveConnection`, `1.2.2` if it also uses `openInConnectionBrowser`, or `1.2.2-beta` if it uses the invocation API. Don't set it higher than necessary; that blocks users on older, otherwise-compatible ToolBox versions from installing the tool at all.

## Checklist

- [ ] Every `toolboxAPI` call is `await`ed and wrapped in error handling (see `add-error-handling`).
- [ ] Multi-connection tools declare `features.multiConnection` (`"optional"` or `"required"`) in `package.json`.
- [ ] Calls that need the secondary connection explicitly pass `'secondary'` as `connectionTarget` — never rely on the default.
- [ ] `package.json`'s `features.minAPI` covers the highest **Requires vX.Y.Z** badge among the methods actually called.
- [ ] No remaining calls to the removed `saveFile()`/`selectPath()` utils — migrated to `toolboxAPI.fileSystem` (see `add-file-system-api`).
- [ ] `openInConnectionBrowser` is only ever called with an `https:`/`http:` URL.
- [ ] `launchTool()` callers branch on a `null` result as "closed without data," not as an error.

## Next steps

- `add-dataverse-api` / `add-powerplatform-api` — the connection info this skill retrieves is what those calls need next
- `add-file-system-api` / `add-events-api` / `add-settings-api` — the rest of the `window.toolboxAPI` surface, documented as their own skills rather than folded in here
- `add-inter-tool-invocation` — when the tool needs a discoverable capability contract instead of a direct `launchTool()` call
- `add-error-handling` — retrofit try/catch and user-facing notifications around the calls this skill adds
- `configure-csp` — if wiring these calls also means the tool now reaches an external domain (e.g. beyond `openInConnectionBrowser`)
