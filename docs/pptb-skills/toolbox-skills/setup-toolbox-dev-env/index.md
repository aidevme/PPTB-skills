---
title: setup-toolbox-dev-env
description: Forks, clones, and bootstraps a local development environment for the Power Platform ToolBox host application.
last_verified: 2026-07-22
---

# setup-toolbox-dev-env

This skill takes a contributor from "I want to work on the ToolBox host" to a running Electron app in development mode. It checks prerequisites, walks through forking and cloning the host repository, installs dependencies with pnpm, and launches `pnpm run dev` — the fastest path to seeing changes running in the actual desktop app rather than only in a test harness.

**Fork the repository, clone your fork, run `pnpm install`, then run `pnpm run dev` to launch the Electron app in development mode.**

## When to use it

- "Set up my dev environment for the ToolBox host."
- "I want to contribute to Power Platform ToolBox — get me started."
- "Clone and run the toolbox host locally."
- "pnpm install is failing" or "pnpm run dev won't launch" — first checks prerequisites before troubleshooting further.
- Before `add-host-manager`, since a working `pnpm run dev` loop is a precondition for making and testing host changes.

## Inputs

- Whether the contributor already has a fork of the host repository, or needs to create one.
- Installed versions of Node.js, pnpm, and Git (to confirm they meet the minimums).
- The editor in use (VS Code is recommended, not required).

## What it does

1. Confirms prerequisites are installed and meet the minimum versions: Node.js 18 or higher, pnpm 10 or higher, Git, and (recommended) VS Code.
2. Guides forking the toolbox host repository on GitHub, if not already done.
3. Clones the fork locally.
4. Runs `pnpm install` to set up dependencies, surfacing any install failures against the version prerequisites first (the most common root cause).
5. Runs `pnpm run dev` to launch the Electron application in development mode.
6. Confirms the app actually launches — this is the signal that the environment is ready for further changes — rather than treating a clean `pnpm install` as sufficient on its own.
7. Points to `add-host-manager` (for extending main-process capability) and the broader ToolBox Development workflow (lint, build, contributing standards, release process) as the next steps once the environment is confirmed working.

## Example

```bash
# Prerequisites check
node --version   # >= 18
pnpm --version    # >= 10
git --version

# Clone your fork
git clone https://github.com/<your-username>/powerplatform-toolbox.git
cd powerplatform-toolbox

# Install and launch
pnpm install
pnpm run dev
```

Expected result: the Electron shell opens as a desktop window, running your fork's code in development mode.

## Checklist it enforces

- [ ] Node.js 18+ and pnpm 10+ are installed.
- [ ] The repository is forked and cloned locally.
- [ ] `pnpm install` completes without errors.
- [ ] `pnpm run dev` launches the Electron app successfully.

## Related

- [Getting Started](/pptb-tools/toolbox-development/getting-started/) — the primary reference this skill is built on
- [ToolBox Development](/pptb-tools/toolbox-development/) — broader workflow (lint, build, contributing standards, release process) once the environment is running
- [add-host-manager](../add-host-manager/) — the natural next skill once `pnpm run dev` is confirmed working
