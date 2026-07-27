# Toolbox development skills catalog

Full descriptions for every skill `toolbox-development` routes to. Use this when the compact table in `SKILL.md` doesn't disambiguate a request.

## `setup-toolbox-dev-env`

Forks and clones the ToolBox host repository, installs prerequisites, and gets a contributor from zero to a running local build.

- Prerequisites: Node.js 18+, pnpm 10+, Git, and (recommended) VS Code.
- Fork the host repository on GitHub, then clone the fork locally.
- Install dependencies with `pnpm install`.
- Launch the Electron app in development mode with `pnpm run dev`.
- Success looks like: the Electron app opens and reflects local changes, not just a test harness.

Use when asked to "set up the ToolBox dev environment", "get the ToolBox host running locally", "fork and clone the ToolBox repo", or "install dependencies for ToolBox development".

## `add-host-manager`

Scaffolds a new main-process manager — a self-contained domain of host state or OS-level integration — following the existing pattern used by the settings, connections, tool-lifecycle, and auth managers.

- Lives in `src/main/`, alongside the existing managers (settings, Dataverse connection CRUD, tool lifecycle/registry, auth via OAuth/MSAL, Dataverse Web API, OS-native encryption, terminal instances, auto-update).
- Communicates with the renderer/tool iframes **only** through `toolboxAPI` / `toolboxAPIBridge.js` — never expose a new manager's functionality directly to a tool's sandboxed iframe, and never give it direct Node.js/Electron API access from the renderer side.
- If the manager handles sensitive data (credentials, tokens, passwords), store it using the OS-native encryption mechanism: Keychain (macOS), DPAPI (Windows), or libsecret (Linux) — never plain text.
- Keep the new manager's concerns isolated — don't mix, e.g., settings logic into a connections manager.

Use when asked to "add a new manager to the ToolBox host", "extend the host's main process", "add a new domain of state to ToolBox", "integrate with a new OS-level capability", or "expose a new capability to tools through toolboxAPI".

## `package-toolbox`

Runs the lint/type-check/build pipeline and produces a platform-specific packaged build from the three Vite bundles (main process, preload script, renderer process).

- `pnpm run lint` — lint checks.
- `pnpm run build` — type-check and build all three bundles.
- `pnpm run package:win` (or the equivalent for macOS/Linux) — produces a platform-specific packaged build.
- Verify all three bundles (main, preload, renderer) still build cleanly after the change before opening a PR.
- Target the `dev` branch, not `main`; nightly pre-releases (`1.0.0-dev.YYYYMMDD`) are cut automatically from `dev`, and stable releases follow a `dev`-to-`main` merge.

Use when asked to "package a ToolBox build", "produce a distributable build", "run the ToolBox build pipeline before a PR", "verify the host still builds after my change", or "cut a release build for Windows/macOS/Linux".
