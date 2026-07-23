---
title: PowerPlatform API
description: The API a PPTB tool uses to interact with Power Platform environments and resources.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/powerplatform-api
last_verified: 2026-07-22
---

# PowerPlatform API

The PowerPlatform API (`window.powerplatformAPI`) gives a tool direct access to Power Platform service endpoints — environment management, governance, licensing, analytics, and more — beyond what the Dataverse API covers. Reach for it when you need to call a Power Platform REST API rather than Dataverse's Web API.

**The surface is organized into service namespaces, and every namespace exposes the same shared HTTP client methods (`Get`, `Post`, `Put`, `Patch`, `Delete`); before any of it works, the connection needs its own Entra app registration wired up and the "Enabled for Power Platform" option turned on.**

For the Microsoft reference, see the [Power Platform REST API documentation](https://learn.microsoft.com/en-us/rest/api/power-platform/). For complete TypeScript definitions, install the `@pptb/types` package:

```bash
npm install --save-dev @pptb/types
```

## Setup requirements

Before using `window.powerplatformAPI`, you must:

1. Create and configure your own Microsoft Entra app registration for Power Platform API authentication, following [Enable programmability and API support](https://learn.microsoft.com/en-us/power-platform/admin/programmability-authentication-v2).
2. Configure the required Power Platform API permissions on that app registration, based on the [Programmability permission reference](https://learn.microsoft.com/en-us/power-platform/admin/programmability-permission-reference).
3. In your Power Platform ToolBox connection settings, populate the App Registration **Client ID**.
4. In that same connection, enable the **Enabled for Power Platform** option.

You can inspect this state from the ToolBox connections API through `Connection.enabledForPowerPlatformAPI` and `Connection.scopesForPowerPlatformAPI` — see [ToolBox API](/pptb-tools/tool-development/toolbox-api/#connections).

## Shared client methods

Every namespace on `window.powerplatformAPI` exposes the same method shape:

- **`Get(path?, connectionTarget?, headers?)`** — make a `GET` request to the namespace endpoint.
- **`Post(path?, body?, connectionTarget?, headers?)`** — make a `POST` request to the namespace endpoint.
- **`Put(path?, body?, connectionTarget?, headers?)`** — make a `PUT` request to the namespace endpoint.
- **`Patch(path?, body?, connectionTarget?, headers?)`** — make a `PATCH` request to the namespace endpoint.
- **`Delete(path?, connectionTarget?, headers?, body?)`** — make a `DELETE` request to the namespace endpoint. A request body is supported when the API requires payload deletion.

**Common parameters:**

- `path?: string` — relative path after the namespace base URL, including query string when needed
- `body?: unknown` — optional request payload for write operations
- `connectionTarget?: 'primary' | 'secondary'` — optional connection target, defaults to `'primary'`
- `headers?: Record<string, string>` — optional custom request headers

**Returns:** `Promise<PowerPlatformResponse>`

```javascript
const powerplatform = window.powerplatformAPI

const response = await powerplatform.EnvironmentManagement.Get(
  'environments?api-version=2024-10-01',
)

console.log(response)
```

## Namespace catalog

The type file currently exposes these namespaces. Each one uses the same shared client methods, so the usage pattern stays consistent — only the namespace and path change:

| Namespace | Example usage |
| ----------- | --------------- |
| `Analytics` | `await powerplatform.Analytics.Get('reports?api-version=2024-10-01')` |
| `AppManagement` | `await powerplatform.AppManagement.Get('apps?api-version=2024-10-01')` |
| `Authorization` | `await powerplatform.Authorization.Get('roles?api-version=2024-10-01')` |
| `Connectivity` | `await powerplatform.Connectivity.Get('connections?api-version=2024-10-01')` |
| `CopilotStudio` | `await powerplatform.CopilotStudio.Get('environments?api-version=2024-10-01')` |
| `Dynamics` | `await powerplatform.Dynamics.Get('environments?api-version=2024-10-01')` |
| `EnvironmentManagement` | `await powerplatform.EnvironmentManagement.Get('environments?api-version=2024-10-01')` |
| `Governance` | `await powerplatform.Governance.Get('policies?api-version=2024-10-01')` |
| `Licensing` | `await powerplatform.Licensing.Get('subscriptions?api-version=2024-10-01')` |
| `PowerApps` | `await powerplatform.PowerApps.Get('environments/{environmentId}/apps/{app}?api-version=2024-10-01')` |
| `PowerAutomate` | `await powerplatform.PowerAutomate.Get('flows?api-version=2024-10-01')` |
| `PowerPages` | `await powerplatform.PowerPages.Get('sites?api-version=2024-10-01')` |
| `ResourceQuery` | `await powerplatform.ResourceQuery.Get('queries?api-version=2024-10-01')` |
| `UserManagement` | `await powerplatform.UserManagement.Get('users?api-version=2024-10-01')` |
| `WorkflowAgents` | `await powerplatform.WorkflowAgents.Get('agents?api-version=2024-10-01')` |

These examples show the naming pattern from the type file and the style of relative paths each namespace accepts. The actual operation path depends on the specific Power Platform API you're calling — consult the [Power Platform REST API documentation](https://learn.microsoft.com/en-us/rest/api/power-platform/) for the endpoint and `api-version` a given operation expects.

## Checklist

- [ ] The connection used by your tool has an Entra app registration Client ID configured and **Enabled for Power Platform** turned on.
- [ ] The app registration has the Power Platform API permissions the calls you make actually require.
- [ ] Calls check `Connection.enabledForPowerPlatformAPI` before attempting a `powerplatformAPI` request, and handle the case where it's `false`.
- [ ] Paths include the correct `api-version` query parameter for the target endpoint.
- [ ] Multi-connection tools pass `connectionTarget` explicitly where the secondary environment's Power Platform access is intended.

## Related links

- [PowerPlatform API (source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/powerplatform-api)
- [Overview](/pptb-tools/tool-development/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
- [ToolBox API](/pptb-tools/tool-development/toolbox-api/)
- [Power Platform REST API documentation](https://learn.microsoft.com/en-us/rest/api/power-platform/)
- [Enable programmability and API support](https://learn.microsoft.com/en-us/power-platform/admin/programmability-authentication-v2)
- [Programmability permission reference](https://learn.microsoft.com/en-us/power-platform/admin/programmability-permission-reference)
