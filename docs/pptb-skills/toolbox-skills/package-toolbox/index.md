---
title: package-toolbox
description: Runs lint, type-check, and build steps for the ToolBox host, then produces a platform-specific packaged build from its three Vite bundles.
last_verified: 2026-07-22
---

# package-toolbox

This skill runs the ToolBox host's build pipeline end to end: lint checks, formatting, type checking, the core build, and — when a distributable is needed — a platform-specific package command. It confirms the three parallel Vite bundles (main process, preload script, renderer process) all build cleanly before producing output, since a change that breaks any one of them breaks the app.

**The typical workflow runs lint checks, formatting, type checking, and a build; platform-specific packages (e.g. `pnpm run package:win`) are a separate step on top of that.**

## When to use it

- "Build the toolbox host and check it's clean."
- "Package a Windows build of the toolbox."
- "Run lint and build before I open a PR."
- "Did my change break the main/preload/renderer bundles?"
- As the last check before opening a pull request against `dev`, after `add-host-manager` or any other host change.

## Inputs

- Whether a full platform package is needed, or just a lint/build verification pass.
- The target platform for packaging (e.g. Windows, via `pnpm run package:win`; other platforms follow the same `package:<platform>` pattern).
- Whether this run is local verification or preparing PR evidence (test results are part of the PR requirements).

## What it does

1. Runs `pnpm run lint` to catch formatting and lint issues.
2. Runs `pnpm run build` to type-check and compile the application.
3. Confirms the build produces its three parallel bundles — the main process bundle, the preload script bundle, and the renderer process bundle — without errors.
4. Confirms the resulting distribution includes compiled JavaScript, SCSS compiled to CSS, static assets, and bundle analysis reports.
5. When a distributable is requested, runs the platform-specific package command, e.g. `pnpm run package:win` for Windows.
6. Surfaces the outcome as evidence for the pull request requirements: a meaningful title, test results, references to related issues, and the PR template checklist — all expected before a PR targeting `dev` is merged.
7. Reminds the contributor of the branch and commit conventions this build feeds into: target `dev` (not `main`), and use Conventional Commits types (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`).

## Example

```bash
# Lint and build verification
pnpm run lint
pnpm run build

# Platform-specific package (Windows)
pnpm run package:win
```

Expected output: lint passes with no errors, `pnpm run build` emits clean main/preload/renderer bundles plus SCSS-compiled CSS and static assets, and `pnpm run package:win` produces the Windows distributable.

## Checklist it enforces

- [ ] `pnpm run lint` passes with no errors.
- [ ] `pnpm run build` completes and produces all three bundles (main, preload, renderer) cleanly.
- [ ] The build output includes compiled JS/CSS, static assets, and bundle analysis reports.
- [ ] The requested platform-specific package command (e.g. `pnpm run package:win`) completes successfully.
- [ ] The pull request targets the `dev` branch and follows Conventional Commits formatting.

## Related

- [ToolBox Development](/pptb-tools/toolbox-development/) — the reference this skill is built on (Development workflow, Contributing standards)
- [Architecture](/pptb-tools/toolbox-development/architecture/) — background on the three-bundle build and output structure
- [add-host-manager](../add-host-manager/) — the change this skill typically verifies before a PR
