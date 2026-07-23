---
title: Architecture
description: How the PPTB toolbox host is structured internally — process model, security, and build output.
source: https://docs.powerplatformtoolbox.com/toolbox-development/architecture
last_verified: 2026-07-22
---

# Architecture

Power Platform ToolBox is an Electron-based desktop application built with TypeScript, Vite, and a modular design pattern. This page covers the host's multi-process architecture, the security model that isolates tools from each other and from the host, and how the build produces its final output — background a contributor needs before making non-trivial changes to the host.

**The host is split into a main process, a renderer process, and an API layer; every tool runs inside a sandboxed iframe with no direct access to Node.js or Electron APIs, communicating only through `toolboxAPIBridge.js`.**

## Core technology stack

- **Electron v28** — cross-platform desktop deployment.
- **TypeScript v5.9.3** — type-safe development.
- **Vite v7.1.11** — the build tool.
- **pnpm v10.18.3+** — package management.
- Supporting libraries include `electron-store`, `electron-updater`, and `@azure/msal-node`.

## Architectural components

### Main process

The main process manages the application lifecycle through managers that each handle a specific domain:

- Settings management, with persistent storage.
- Dataverse connection CRUD operations.
- Tool lifecycle and registry management.
- Authentication, via OAuth and MSAL.
- Dataverse Web API operations.
- OS-native encryption for sensitive data.
- Terminal instance creation and command execution.
- Auto-update functionality.

### Renderer process

The renderer process handles the user interface: an HTML structure, SCSS styling, TypeScript logic, and iframes that host each running tool in isolation.

### API layer

The API layer provides event-driven communication through `toolboxAPI`, enabling notifications, event subscriptions, and application messaging between the host and its tools.

## Security architecture

Each tool runs in a separate sandboxed iframe with limited API access. Communication happens through structured `postMessage` protocols with automatic context injection. Tools receive their APIs through `toolboxAPIBridge.js` and **cannot** directly access Node.js or Electron APIs.

Sensitive data (client credentials, access tokens, passwords) is protected with OS-native encryption:

| OS | Mechanism |
| --- | --- |
| macOS | Keychain |
| Windows | DPAPI |
| Linux | libsecret |

## Build and output structure

The Vite build produces three parallel bundles:

- The main process bundle.
- The preload script bundle.
- The renderer process bundle.

The resulting distribution includes compiled JavaScript, SCSS compiled to CSS, static assets, and bundle analysis reports.

## Checklist

- [ ] Changes to main-process logic stay within the appropriate manager (settings, connections, tool lifecycle, auth, Dataverse Web API, encryption, terminal, or auto-update) rather than mixing concerns.
- [ ] Any new communication path between host and tool goes through `toolboxAPI` / `toolboxAPIBridge.js`, not a direct Node.js or Electron API exposed to the iframe.
- [ ] Sensitive data introduced by a change is stored using the OS-native encryption mechanism (Keychain/DPAPI/libsecret), not in plain text.
- [ ] The three build bundles (main, preload, renderer) still build cleanly after the change.

## Related links

- [Power Platform ToolBox Architecture Overview (upstream source)](https://docs.powerplatformtoolbox.com/toolbox-development/architecture)
- [ToolBox Development](/pptb-tools/toolbox-development/)
- [Getting Started](/pptb-tools/toolbox-development/getting-started/)
