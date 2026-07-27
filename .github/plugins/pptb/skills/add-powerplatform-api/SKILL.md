---
name: add-powerplatform-api
description: Wires up `window.powerplatformAPI` namespace calls (environment management, governance, licensing, analytics, and the rest of the Power Platform REST surface) and the Entra app registration prerequisites they depend on. Use when asked to "call the Power Platform environment management API", "list environments/governance policies/licensing subscriptions from my tool", "check whether this connection is enabled for Power Platform API", "query analytics/app management/Copilot Studio/PowerApps/PowerAutomate/PowerPages from my tool", or when a `powerplatformAPI` call is failing/unauthorized.
---

# Add PowerPlatform API

The PowerPlatform API (`window.powerplatformAPI`) gives a tool direct access to Power Platform service endpoints — environment management, governance, licensing, analytics, and more — beyond what `dataverseAPI`'s Web API surface covers. Reach for it when the tool needs to call a Power Platform REST API rather than Dataverse's Web API.

**The surface is organized into service namespaces, and every namespace exposes the same shared HTTP client methods (`Get`, `Post`, `Put`, `Patch`, `Delete`). None of it works until the connection has its own Entra app registration Client ID configured and "Enabled for Power Platform" turned on — check `Connection.enabledForPowerPlatformAPI` before attempting any call, and guide the developer through setup if it's `false`.**

## Step 1: Verify (or set up) the connection prerequisites

Before generating any `powerplatformAPI` call, confirm the target connection is actually usable for it:

1. An Entra app registration exists for Power Platform API authentication — [Enable programmability and API support](https://learn.microsoft.com/en-us/power-platform/admin/programmability-authentication-v2).
2. That app registration has the permissions the calls need — [Programmability permission reference](https://learn.microsoft.com/en-us/power-platform/admin/programmability-permission-reference).
3. The connection's **App Registration Client ID** is populated in ToolBox connection settings.
4. **Enabled for Power Platform** is turned on for that connection.

If any of this is missing, walk the developer through it rather than generating a call that will fail — none of the namespaces work without all four in place.

## Step 2: Guard every call on `enabledForPowerPlatformAPI`

Check the connection's `enabledForPowerPlatformAPI` flag (via `toolboxAPI.connections.getActiveConnection()` / `getSecondaryConnection()` — see `add-toolbox-api`) before attempting a `powerplatformAPI` request, and handle the `false` case with a clear message rather than letting the request fail:

```typescript
const connection = await toolboxAPI.connections.getActiveConnection()

if (!connection?.enabledForPowerPlatformAPI) {
  await toolboxAPI.utils.showNotification({
    title: 'Power Platform API not enabled',
    body: 'Enable "Enabled for Power Platform" on this connection to use this feature.',
    type: 'warning',
  })
  return
}
```

## Step 3: Identify the correct namespace

`window.powerplatformAPI` exposes one namespace per Power Platform service area. Every namespace shares the same client methods — only the namespace and path change:

| Namespace | Example usage |
| --- | --- |
| `Analytics` | `powerplatform.Analytics.Get('reports?api-version=2024-10-01')` |
| `AppManagement` | `powerplatform.AppManagement.Get('apps?api-version=2024-10-01')` |
| `Authorization` | `powerplatform.Authorization.Get('roles?api-version=2024-10-01')` |
| `Connectivity` | `powerplatform.Connectivity.Get('connections?api-version=2024-10-01')` |
| `CopilotStudio` | `powerplatform.CopilotStudio.Get('environments?api-version=2024-10-01')` |
| `Dynamics` | `powerplatform.Dynamics.Get('environments?api-version=2024-10-01')` |
| `EnvironmentManagement` | `powerplatform.EnvironmentManagement.Get('environments?api-version=2024-10-01')` |
| `Governance` | `powerplatform.Governance.Get('policies?api-version=2024-10-01')` |
| `Licensing` | `powerplatform.Licensing.Get('subscriptions?api-version=2024-10-01')` |
| `PowerApps` | `powerplatform.PowerApps.Get('environments/{environmentId}/apps/{app}?api-version=2024-10-01')` |
| `PowerAutomate` | `powerplatform.PowerAutomate.Get('flows?api-version=2024-10-01')` |
| `PowerPages` | `powerplatform.PowerPages.Get('sites?api-version=2024-10-01')` |
| `ResourceQuery` | `powerplatform.ResourceQuery.Get('queries?api-version=2024-10-01')` |
| `UserManagement` | `powerplatform.UserManagement.Get('users?api-version=2024-10-01')` |
| `WorkflowAgents` | `powerplatform.WorkflowAgents.Get('agents?api-version=2024-10-01')` |

These show the naming pattern and the relative-path style each namespace accepts — the actual operation path and required permissions still depend on the specific Power Platform API being called.

## Step 4: Call the shared client methods

Every namespace exposes the same five methods:

- **`Get(path?, connectionTarget?, headers?)`**
- **`Post(path?, body?, connectionTarget?, headers?)`**
- **`Put(path?, body?, connectionTarget?, headers?)`**
- **`Patch(path?, body?, connectionTarget?, headers?)`**
- **`Delete(path?, connectionTarget?, headers?, body?)`** — accepts a request body for APIs that require payload deletion

`path` is relative to the namespace's base URL and should include the query string (including `api-version`). `connectionTarget` defaults to `'primary'`; pass `'secondary'` explicitly for multi-connection tools targeting the second environment. Only add `headers` when the specific endpoint requires something beyond the defaults.

```typescript
const response = await window.powerplatformAPI.EnvironmentManagement.Get(
  'environments?api-version=2024-10-01',
)
console.log(response)
```

## Step 5: Look up the operation's path and `api-version`

Don't guess the path shape or `api-version` — look up the specific operation in the [Power Platform REST API documentation](https://learn.microsoft.com/en-us/rest/api/power-platform/) for the namespace being called, and use the `api-version` that documentation specifies for that operation. Different operations within the same namespace can use different `api-version` values.

## Checklist

- [ ] The connection used by the tool has an Entra app registration Client ID configured and **Enabled for Power Platform** turned on.
- [ ] The app registration has the Power Platform API permissions the calls actually require.
- [ ] Calls check `Connection.enabledForPowerPlatformAPI` before attempting a `powerplatformAPI` request, and handle the case where it's `false`.
- [ ] Paths include the correct `api-version` query parameter for the target endpoint, sourced from the Power Platform REST API documentation.
- [ ] Multi-connection tools pass `connectionTarget` explicitly where the secondary environment's Power Platform access is intended.

## Next steps

- `add-toolbox-api` — retrieves the `Connection` used to check `enabledForPowerPlatformAPI` in Step 2
- `add-dataverse-api` — for Dataverse Web API operations this API doesn't cover
- `add-error-handling` — wrap these calls in try/catch and surface API failures (e.g. `401`/`403` from a missing permission) to the user
