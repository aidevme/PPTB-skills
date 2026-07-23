---
title: Getting Started
description: How to set up your local environment to build and run the PPTB toolbox host.
last_verified: 2026-07-22
---

# Getting Started

This page covers the basic steps for setting up a local development environment for the Power Platform ToolBox **host application** — the Electron app that loads and runs tools — before you make any changes. It's deliberately brief; see [Architecture](/pptb-tools/toolbox-development/architecture/) once your environment is running and you're ready to understand how the host is structured internally.

**Fork the repository, clone your fork, run `pnpm install`, then run `pnpm run dev` to launch the Electron app in development mode.**

## Prerequisites

Before you start, make sure you have:

- Node.js 18 or higher.
- pnpm 10 or higher.
- Git.
- VS Code (recommended editor).

## Setting up the repository

1. Fork the toolbox host repository on GitHub.
2. Clone your fork locally.
3. Install dependencies:

   ```bash
   pnpm install
   ```

## Running the host in development mode

Launch the Electron application in development mode:

```bash
pnpm run dev
```

This starts the host so you can see your changes running in the actual desktop app rather than only in a test harness.

## Where to go next

- [Architecture](/pptb-tools/toolbox-development/architecture/) explains the main process, renderer process, and API layer you'll be working with.
- The [ToolBox Development](/pptb-tools/toolbox-development/) overview covers the broader development workflow — linting, building, contributing standards, and the release process — once your environment is up and running.

## Checklist

- [ ] Node.js 18+ and pnpm 10+ are installed.
- [ ] The repository is forked and cloned locally.
- [ ] `pnpm install` completes without errors.
- [ ] `pnpm run dev` launches the Electron app successfully.

## Related links

- [ToolBox Development](/pptb-tools/toolbox-development/)
- [Architecture](/pptb-tools/toolbox-development/architecture/)
