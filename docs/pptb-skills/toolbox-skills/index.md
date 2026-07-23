---
title: Toolbox Skills
description: A catalog of skill specifications for contributors building the Power Platform ToolBox host application itself.
last_verified: 2026-07-22
---

# Toolbox Skills

These skill specifications target contributors working on the Power Platform ToolBox **host application** — the Electron shell that loads and runs tools — as distinct from the tool-development skills that help build tools that run inside it. Each skill automates a step in the contributor workflow: getting a fork running locally, extending the host's main-process capabilities, or producing a distributable build.

| Skill | Description |
| --- | --- |
| [setup-toolbox-dev-env](./setup-toolbox-dev-env/) | Forks and clones the ToolBox host repo, installs prerequisites, runs `pnpm install`, and launches the Electron app in development mode with `pnpm run dev`. |
| [add-host-manager](./add-host-manager/) | Scaffolds a new main-process manager (following the existing settings/connections/tool-lifecycle/auth pattern) that communicates with the renderer only through `toolboxAPI` / `toolboxAPIBridge.js`. |
| [package-toolbox](./package-toolbox/) | Runs lint, type-check, and build steps, then produces a platform-specific packaged build (e.g. `pnpm run package:win`) from the three Vite bundles. |

## How these skills fit together

A contributor typically runs `setup-toolbox-dev-env` once, to get `pnpm run dev` working locally. From there, `add-host-manager` is used whenever a change needs new main-process capability — a new domain of state or a new OS-level integration — kept properly isolated behind the API layer rather than exposed directly to tool iframes. Once a change is ready, `package-toolbox` verifies the lint/build/package pipeline still produces clean main, preload, and renderer bundles before the change goes into a pull request targeting the `dev` branch.

## Related

- [ToolBox Development](/pptb-tools/toolbox-development/) — the reference these skills are built on
- [Tool Skills](../tool-skills/) — the companion catalog for building tools that run inside the toolbox, rather than the toolbox itself
