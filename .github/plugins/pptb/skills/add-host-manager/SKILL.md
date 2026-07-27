---
name: add-host-manager
description: Scaffolds a new main-process manager for the Power Platform ToolBox host, following the existing settings/connections/tool-lifecycle/auth pattern and wired through `toolboxAPI`/`toolboxAPIBridge.js` so tools never get direct Node.js or Electron access. Use when asked to "add a new manager to the toolbox host for X", "the main process needs to handle a new kind of persistent state", "expose a new host capability to tools without breaking the sandbox", or "where does this new Node.js-side logic belong in the host" — typically right after `setup-toolbox-dev-env`, when a change needs new main-process capability rather than a renderer-only UI change.
---

# Add Host Manager

The Power Platform ToolBox host's main process is organized into managers, each owning one domain — settings, Dataverse connections, tool lifecycle, authentication, Dataverse Web API operations, OS-native encryption, terminal handling, auto-update. This skill scaffolds a new manager following that same pattern, so new host capability lands in the right place instead of getting bolted onto an unrelated existing manager.

**The host is split into a main process, a renderer process, and an API layer; every tool runs inside a sandboxed iframe with no direct access to Node.js or Electron APIs, communicating only through `toolboxAPI`/`toolboxAPIBridge.js` — a new manager's tool-facing surface, if any, must go through that bridge and nowhere else.**

## Step 1: Scope the manager to one domain

Before writing any code, confirm the new manager owns a single, well-defined responsibility — the same way Dataverse connection CRUD is its own manager rather than folded into settings. If the request describes two unrelated concerns ("handle environment variables and also manage terminal themes"), that's two managers, not one.

## Step 2: Place it in `src/main/`

Add the new manager under `src/main/`, alongside the existing managers, rather than mixing its logic into settings, connections, tool lifecycle, auth, Dataverse Web API, encryption, terminal, or auto-update:

```typescript
// src/main/managers/environment-variables-manager.ts
export class EnvironmentVariablesManager {
  // Owns one domain: environment-variable CRUD, nothing else.
  async get(key: string): Promise<string | undefined> {
    /* ... */
  }

  async set(key: string, value: string, sensitive = false): Promise<void> {
    if (sensitive) {
      // Routed through OS-native encryption — never stored in plain text.
      return this.encryptionService.store(key, value)
    }
    return this.store.set(key, value)
  }
}
```

## Step 3: Wire renderer/tool-facing exposure through the API layer only

Any communication the manager needs with the renderer or with a running tool goes through `toolboxAPI` on the API layer, using structured `postMessage` protocols with automatic context injection — never a direct Node.js or Electron API exposed to a tool's sandboxed iframe:

```typescript
// src/preload/toolboxAPIBridge.js
contextBridge.exposeInMainWorld('toolboxAPI', {
  getEnvironmentVariable: (key) => ipcRenderer.invoke('env-vars:get', key),
})
```

If the manager has no tool-facing surface at all (purely internal host state), this step doesn't apply — but if it does, `toolboxAPIBridge.js` is the only path in.

## Step 4: Encrypt anything sensitive

If the manager stores client credentials, access tokens, passwords, or anything else sensitive, route it through the OS-native encryption mechanism for the current platform rather than plain text:

| OS | Mechanism |
| --- | --- |
| macOS | Keychain |
| Windows | DPAPI |
| Linux | libsecret |

## Step 5: Confirm the three build bundles still build

A new manager touches the main process, and often the preload script if it exposes anything through `toolboxAPIBridge.js`. Confirm all three parallel Vite bundles — main, preload, renderer — still build cleanly before considering the manager done; see `package-toolbox` for the actual lint/build/package pipeline.

## Checklist

- [ ] Changes to main-process logic stay within the appropriate manager (settings, connections, tool lifecycle, auth, Dataverse Web API, encryption, terminal, or auto-update) rather than mixing concerns.
- [ ] Any new communication path between host and tool goes through `toolboxAPI` / `toolboxAPIBridge.js`, not a direct Node.js or Electron API exposed to the iframe.
- [ ] Sensitive data introduced by a change is stored using the OS-native encryption mechanism (Keychain/DPAPI/libsecret), not in plain text.
- [ ] The three build bundles (main, preload, renderer) still build cleanly after the change.

## Next steps

- `setup-toolbox-dev-env` — get `pnpm run dev` running before scaffolding a new manager
- `package-toolbox` — verify the manager builds and packages cleanly once added
- `docs/pptb-tools/toolbox-development/architecture/` — the reference this skill is built on
