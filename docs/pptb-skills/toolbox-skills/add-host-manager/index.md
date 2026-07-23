---
title: add-host-manager
description: Scaffolds a new main-process manager for the ToolBox host, wired through toolboxAPI so tools never get direct Node.js or Electron access.
last_verified: 2026-07-22
---

# add-host-manager

This skill scaffolds a new main-process manager for the Power Platform ToolBox host — the pattern the host already uses for settings, Dataverse connections, tool lifecycle, authentication, Dataverse Web API operations, encryption, terminal handling, and auto-update. It places new logic in `src/main/` under its own manager, wires any renderer-facing communication through the API layer, and applies OS-native encryption to anything sensitive the manager touches.

**The host is split into a main process, a renderer process, and an API layer; every tool runs inside a sandboxed iframe with no direct access to Node.js or Electron APIs, communicating only through `toolboxAPIBridge.js`.**

## When to use it

- "Add a new manager to the toolbox host for X."
- "I need the main process to handle a new kind of persistent state."
- "Expose a new host capability to tools without breaking the sandbox."
- "Where does this new Node.js-side logic belong in the host?"
- After `setup-toolbox-dev-env`, when a change requires new main-process capability rather than a renderer-only UI change.

## Inputs

- The domain the new manager owns (a specific, single responsibility — not a grab-bag of unrelated logic).
- Whether the manager needs persistent storage, and whether any of that data is sensitive (client credentials, access tokens, passwords).
- Which renderer-side or tool-side interactions the manager needs to support, and whether they should be exposed to tool iframes via `toolboxAPI` at all.
- The target platform(s) for any OS-native encryption requirements (macOS Keychain, Windows DPAPI, Linux libsecret).

## What it does

1. Places the new manager in `src/main/`, following the existing separation of concerns rather than mixing it into an unrelated existing manager (settings, connections, tool lifecycle, auth, Dataverse Web API, encryption, terminal, auto-update).
2. Scopes the manager to a single domain, matching the pattern of the host's existing managers (e.g., Dataverse connection CRUD is its own manager, not folded into settings).
3. Wires any renderer-to-main or tool-to-main communication through `toolboxAPI` on the API layer, using structured `postMessage` protocols with automatic context injection — never a direct Node.js or Electron API exposed to a tool's sandboxed iframe.
4. Ensures tool-facing capability (if any) is only reachable through `toolboxAPIBridge.js`, preserving the sandbox: tools cannot directly access Node.js or Electron APIs.
5. Routes any sensitive data the manager handles (client credentials, access tokens, passwords) through the OS-native encryption mechanism for the current platform — Keychain on macOS, DPAPI on Windows, libsecret on Linux — instead of storing it in plain text.
6. Confirms the change doesn't break the three parallel Vite build bundles: main process, preload script, and renderer process.
7. Flags the change for `package-toolbox` (lint, build, and platform packaging) once the manager is complete.

## Example

A new manager added under `src/main/`, following the existing pattern:

```typescript
// src/main/managers/environment-variables-manager.ts
export class EnvironmentVariablesManager {
  // Owns one domain: environment-variable CRUD, nothing else.
  async get(key: string): Promise<string | undefined> { /* ... */ }
  async set(key: string, value: string, sensitive = false): Promise<void> {
    if (sensitive) {
      // Routed through OS-native encryption — never stored in plain text.
      return this.encryptionService.store(key, value);
    }
    return this.store.set(key, value);
  }
}
```

Renderer/tool-facing exposure goes through the API layer, not a direct import:

```typescript
// src/preload/toolboxAPIBridge.js
contextBridge.exposeInMainWorld('toolboxAPI', {
  getEnvironmentVariable: (key) => ipcRenderer.invoke('env-vars:get', key),
});
```

## Checklist it enforces

- [ ] Changes to main-process logic stay within the appropriate manager (settings, connections, tool lifecycle, auth, Dataverse Web API, encryption, terminal, or auto-update) rather than mixing concerns.
- [ ] Any new communication path between host and tool goes through `toolboxAPI` / `toolboxAPIBridge.js`, not a direct Node.js or Electron API exposed to the iframe.
- [ ] Sensitive data introduced by a change is stored using the OS-native encryption mechanism (Keychain/DPAPI/libsecret), not in plain text.
- [ ] The three build bundles (main, preload, renderer) still build cleanly after the change.

## Related

- [Architecture](/pptb-tools/toolbox-development/architecture/) — the reference this skill is built on
- [setup-toolbox-dev-env](../setup-toolbox-dev-env/) — get `pnpm run dev` running before scaffolding a new manager
- [package-toolbox](../package-toolbox/) — verify the manager builds and packages cleanly once added
