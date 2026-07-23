---
title: ToolBox Development
description: What ToolBox development covers for contributors building the Power Platform Toolbox host itself.
source: https://docs.powerplatformtoolbox.com/toolbox-development
last_verified: 2026-07-22
---

# ToolBox Development

This section is for contributors working on the Power Platform ToolBox **host application** itself — the Electron shell that loads and runs tools — as distinct from building a tool that runs inside it. It covers the technology stack, how the project is organized, and the workflow for getting a change from a fork into a release.

**Power Platform ToolBox is built with Electron, TypeScript, Vite, SCSS, and pnpm; contribute by forking the repo, running `pnpm install` and `pnpm run dev`, and targeting your pull request at the `dev` branch.**

## Technology stack

The host application is built with:

- **Electron** — the desktop application framework.
- **TypeScript**
- **Vite**
- **SCSS**
- **pnpm** — the package manager used across the project.

## Prerequisites

To contribute to the host, you need:

- Node.js 18 or higher.
- pnpm 10 or higher.
- Git.
- VS Code (recommended editor).

## Getting started

New contributors fork the repository, clone their fork locally, and run:

```bash
pnpm install
```

to set up dependencies. Start development mode with:

```bash
pnpm run dev
```

For a step-by-step walkthrough, see [Getting Started](/pptb-tools/toolbox-development/getting-started/).

## Project organization

The codebase separates concerns across a few key directories:

- `src/main/` — the main process, handling Node.js-side operations.
- `src/renderer/` — the renderer process, managing the UI.
- An API layer that facilitates communication between the main and renderer processes.

See [Architecture](/pptb-tools/toolbox-development/architecture/) for a deeper look at how these pieces fit together.

## Development workflow

The typical workflow involves running lint checks, formatting code, type checking, and building the application:

```bash
pnpm run lint
pnpm run build
```

Platform-specific builds are available too, for example:

```bash
pnpm run package:win
```

## Contributing standards

- Target the `dev` branch with your pull requests, not `main`.
- Follow the [Conventional Commits](https://www.conventionalcommits.org/) format, using types such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, and `ci`.

## Pull request requirements

Pull requests must include a meaningful title, test results, references to related issues, and completion of the provided PR template checklist before they're merged into `dev`.

## Release strategy

- **Nightly pre-releases** are generated automatically from merges into `dev`, using the version format `1.0.0-dev.YYYYMMDD`.
- **Stable releases** follow a `dev`-to-`main` branch merge.

## Related links

- [Power Platform ToolBox Development Documentation (upstream source)](https://docs.powerplatformtoolbox.com/toolbox-development)
- [Getting Started](/pptb-tools/toolbox-development/getting-started/)
- [Architecture](/pptb-tools/toolbox-development/architecture/)
