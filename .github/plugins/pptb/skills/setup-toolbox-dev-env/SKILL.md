---
name: setup-toolbox-dev-env
description: Forks, clones, and bootstraps a local development environment for the Power Platform ToolBox host application. Use when asked to "set up my dev environment for the ToolBox host", "I want to contribute to Power Platform ToolBox", "clone and run the toolbox host locally", "pnpm install is failing", or "pnpm run dev won't launch" — typically the first skill a contributor needs, and a precondition for `add-host-manager`.
---

# Setup Toolbox Dev Env

This skill takes a contributor from "I want to work on the ToolBox host" to a running Electron app in development mode. It checks prerequisites, walks through forking and cloning the host repository, installs dependencies with pnpm, and launches `pnpm run dev` — the fastest path to seeing changes running in the actual desktop app rather than only in a test harness.

**Fork the repository, clone your fork, run `pnpm install`, then run `pnpm run dev` to launch the Electron app in development mode.**

## Step 1: Confirm prerequisites

Before touching the repository, verify these are installed and meet the minimum versions — most `pnpm install`/`pnpm run dev` failures trace back to one of these being missing or too old:

```bash
node --version   # >= 18
pnpm --version    # >= 10
git --version
```

VS Code is the recommended editor, though not required.

## Step 2: Fork and clone

Fork the ToolBox host repository (`PowerPlatformToolBox/desktop-app`) on GitHub if not already done, then clone the fork locally:

```bash
git clone https://github.com/<your-username>/desktop-app.git
cd desktop-app
```

## Step 3: Install dependencies

```bash
pnpm install
```

If this fails, re-check Step 1's version prerequisites first — that's the most common root cause, not a project-specific problem.

## Step 4: Launch development mode

```bash
pnpm run dev
```

## Step 5: Confirm the app actually launches

The signal that the environment is ready isn't a clean `pnpm install` — it's the Electron shell actually opening as a desktop window, running the fork's code. Don't treat installation alone as sufficient; confirm the app launches before moving on to making changes.

## Example

```bash
# Prerequisites check
node --version   # >= 18
pnpm --version    # >= 10
git --version

# Clone your fork
git clone https://github.com/<your-username>/desktop-app.git
cd desktop-app

# Install and launch
pnpm install
pnpm run dev
```

Expected result: the Electron shell opens as a desktop window, running your fork's code in development mode.

## Checklist

- [ ] Node.js 18+ and pnpm 10+ are installed.
- [ ] The repository is forked and cloned locally.
- [ ] `pnpm install` completes without errors.
- [ ] `pnpm run dev` launches the Electron app successfully.

## Next steps

- `add-host-manager` — the natural next skill once `pnpm run dev` is confirmed working, for adding new main-process capability
- `package-toolbox` — the lint/build/package pipeline once a change is ready for a PR
- `docs/pptb-tools/toolbox-development/getting-started/` — the reference this skill is built on
