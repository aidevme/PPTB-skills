---
title: add-powerplatform-api
description: Wires up window.powerplatformAPI namespace calls and the Entra app registration prerequisites they depend on.
last_verified: 2026-07-22
---

# add-powerplatform-api

This skill automates adding `window.powerplatformAPI` calls to a PPTB tool for functionality the Dataverse API doesn't cover — environment management, governance, licensing, analytics, and the rest of the Power Platform REST surface. A developer reaches for it whenever the tool needs to call a Power Platform service endpoint directly rather than Dataverse's Web API, and it also walks through the connection-level setup those calls depend on.

**Before generating any `powerplatformAPI` call, the skill verifies the connection has an Entra app registration Client ID configured and `enabledForPowerPlatformAPI` turned on — every namespace shares the same `Get`/`Post`/`Put`/`Patch`/`Delete` client methods, but none of it works until that setup is in place.**

## When to use it

- "Call the Power Platform environment management API"
- "List environments / governance policies / licensing subscriptions from my tool"
- "Check whether this connection is enabled for Power Platform API"
- "Query analytics / app management / connectivity / Copilot Studio / Dynamics / PowerApps / PowerAutomate / PowerPages / resource query / user management / workflow agents from my tool"
- "My powerplatformAPI call is failing / unauthorized"

## Inputs

- Which namespace the tool needs: `Analytics`, `AppManagement`, `Authorization`, `Connectivity`, `CopilotStudio`, `Dynamics`, `EnvironmentManagement`, `Governance`, `Licensing`, `PowerApps`, `PowerAutomate`, `PowerPages`, `ResourceQuery`, `UserManagement`, or `WorkflowAgents`
- The specific REST operation (path, `api-version`, HTTP method) — looked up in the [Power Platform REST API documentation](https://learn.microsoft.com/en-us/rest/api/power-platform/) when not already known
- Whether the call targets the primary or secondary connection
- Confirmation that the connection's Entra app registration Client ID is set and **Enabled for Power Platform** is turned on

## What it does

1. Checks `Connection.enabledForPowerPlatformAPI` (via `toolboxAPI.connections.getActiveConnection()` / `getSecondaryConnection()`) before attempting a `powerplatformAPI` request, and generates a guarded early-return or user-facing message for the case where it's `false`.
2. Surfaces the setup prerequisites when they're missing: create an Entra app registration per [Enable programmability and API support](https://learn.microsoft.com/en-us/power-platform/admin/programmability-authentication-v2), grant the permissions in the [Programmability permission reference](https://learn.microsoft.com/en-us/power-platform/admin/programmability-permission-reference), then populate the app registration Client ID and enable **Enabled for Power Platform** in the ToolBox connection settings.
3. Generates the call against the correct namespace using the shared client method shape — `powerplatform.<Namespace>.Get(path?, connectionTarget?, headers?)`, `.Post(path?, body?, connectionTarget?, headers?)`, `.Put(...)`, `.Patch(...)`, `.Delete(path?, connectionTarget?, headers?, body?)`.
4. Includes the correct `api-version` query parameter in `path` for the target endpoint, sourced from the Power Platform REST API documentation for that operation.
5. Passes `connectionTarget: 'primary' | 'secondary'` explicitly whenever the call is meant for a multi-connection tool's secondary environment.
6. Adds `headers` only when the specific endpoint requires custom headers beyond the defaults.

## Example

Before: a tool with no environment-management call.

After:

```typescript
const connection = await toolboxAPI.connections.getActiveConnection()

if (!connection?.enabledForPowerPlatformAPI) {
  await toolboxAPI.utils.showNotification({
    title: 'Power Platform API not enabled',
    body: 'Enable "Enabled for Power Platform" on this connection to use this feature.',
    type: 'warning',
  })
} else {
  const response = await window.powerplatformAPI.EnvironmentManagement.Get(
    'environments?api-version=2024-10-01',
  )
  console.log(response)
}
```

## Checklist it enforces

- [ ] The connection used by the tool has an Entra app registration Client ID configured and **Enabled for Power Platform** turned on.
- [ ] The app registration has the Power Platform API permissions the calls actually require.
- [ ] Calls check `Connection.enabledForPowerPlatformAPI` before attempting a `powerplatformAPI` request, and handle the case where it's `false`.
- [ ] Paths include the correct `api-version` query parameter for the target endpoint.
- [ ] Multi-connection tools pass `connectionTarget` explicitly where the secondary environment's Power Platform access is intended.

## Related

- [PowerPlatform API](/pptb-tools/tool-development/powerplatform-api/) — the API reference this skill is built on
- Related skills: `../add-toolbox-api/`, `../add-dataverse-api/`
