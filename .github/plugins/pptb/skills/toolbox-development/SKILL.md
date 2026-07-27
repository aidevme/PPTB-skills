---
name: toolbox-development
description: Entry point for contributing to the Power Platform ToolBox host application itself — the Electron shell that loads and runs tools. Use when asked to "contribute to the ToolBox host", "set up the ToolBox dev environment", "add a new manager to the ToolBox host", "package a ToolBox build", "work on the Electron app", or any request about the host application's own codebase where it isn't yet clear which specific skill applies — this skill routes to the right one. Not for building a tool that runs inside ToolBox (see `tool-development`).
---

# Toolbox Development

Power Platform ToolBox is an Electron desktop application built with TypeScript, Vite, SCSS, and pnpm. This skill is the starting point for anyone contributing to the host application itself — the codebase that loads and runs tools — as distinct from building a tool that runs inside it. It doesn't set up an environment, scaffold a manager, or build anything itself; it identifies which of the more specific toolbox-development skills the request actually needs.

**The host is split into a main process, a renderer process, and an API layer; every tool runs inside a sandboxed iframe with no direct access to Node.js or Electron APIs, communicating only through `toolboxAPI`/`toolboxAPIBridge.js` — a change to host behavior almost always means touching one of these three layers, never exposing something to the iframe directly.**

## Which skill do I need?

| The request is about... | Reach for | Covers |
| --- | --- | --- |
| Getting a fork of the host running locally for the first time | `setup-toolbox-dev-env` | Fork, clone, `pnpm install`, `pnpm run dev` |
| Adding new main-process capability — a new domain of state, a new OS-level integration | `add-host-manager` | Scaffolding a new manager following the settings/connections/tool-lifecycle/auth pattern, wired through `toolboxAPI`/`toolboxAPIBridge.js` only |
| Verifying a change builds cleanly, or producing a distributable build | `package-toolbox` | Lint, type-check, build, `pnpm run package:<platform>` across the three Vite bundles (main/preload/renderer) |

If the compact table above doesn't disambiguate a request, see `references/skills-catalog.md` for a fuller description of each skill. If the request is about the host's internal architecture rather than a task to perform, check `docs/pptb-tools/toolbox-development/architecture/` before improvising.

## Typical contributor workflow

A contributor typically runs `setup-toolbox-dev-env` once, to get `pnpm run dev` working locally. From there, `add-host-manager` is used whenever a change needs new main-process capability, kept properly isolated behind the API layer rather than exposed directly to tool iframes. Once a change is ready, `package-toolbox` verifies the lint/build/package pipeline still produces clean main, preload, and renderer bundles before the change goes into a pull request targeting the `dev` branch — never `main` directly. Follow Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`) for commit messages, and include a meaningful PR title, test results, and related issue references per the project's PR template.

## Related

- `tool-development` — the sibling entry point for building a tool that runs inside the ToolBox host, rather than the host itself
- `docs/pptb-tools/toolbox-development/` — the architecture/workflow reference this skill is built on
