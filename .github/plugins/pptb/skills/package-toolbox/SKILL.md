---
name: package-toolbox
description: Runs lint, type-check, and build steps for the ToolBox host, then produces a platform-specific packaged build from its three Vite bundles. Use when asked to "build the toolbox host and check it's clean", "package a Windows build of the toolbox", "run lint and build before I open a PR", or "did my change break the main/preload/renderer bundles" — typically the last check before opening a pull request against `dev`, after `add-host-manager` or any other host change.
---

# Package Toolbox

This skill runs the ToolBox host's build pipeline end to end: lint checks, type checking, the core build, and — when a distributable is needed — a platform-specific package command. It confirms the three parallel Vite bundles (main process, preload script, renderer process) all build cleanly before producing output, since a change that breaks any one of them breaks the app.

**The typical workflow runs lint checks and a build first; a platform-specific package (e.g. `pnpm run package:win`) is a separate step on top of that, only needed when a distributable is actually required.**

## Step 1: Lint

```bash
pnpm run lint
```

Fix any reported lint/formatting issues before continuing — don't proceed to build with known lint failures.

## Step 2: Build and verify all three bundles

```bash
pnpm run build
```

This type-checks and compiles the application, producing three parallel bundles:

- The main process bundle.
- The preload script bundle.
- The renderer process bundle.

Confirm the build actually produced all three without errors, and that the resulting distribution includes compiled JavaScript, SCSS compiled to CSS, static assets, and bundle analysis reports — a build that silently drops one of the three bundles is still a broken build even if the command exits `0`.

## Step 3: Package for a target platform, only if a distributable is needed

```bash
pnpm run package:win
```

Other platforms follow the same `package:<platform>` pattern. Skip this step entirely for a plain lint/build verification pass — only run it when the request is actually asking for a distributable.

## Step 4: Surface the result as PR evidence

Once lint, build, and (if requested) packaging all pass, that output is the evidence a pull request needs: a meaningful title, test results, references to related issues, and completion of the PR template checklist — all expected before a PR targeting `dev` is merged.

Remind the contributor of the conventions this build feeds into:

- Target the `dev` branch, not `main`.
- Use Conventional Commits types (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`) for commit messages.

## Example

```bash
# Lint and build verification
pnpm run lint
pnpm run build

# Platform-specific package (Windows)
pnpm run package:win
```

Expected output: lint passes with no errors, `pnpm run build` emits clean main/preload/renderer bundles plus SCSS-compiled CSS and static assets, and `pnpm run package:win` produces the Windows distributable.

## Checklist

- [ ] `pnpm run lint` passes with no errors.
- [ ] `pnpm run build` completes and produces all three bundles (main, preload, renderer) cleanly.
- [ ] The build output includes compiled JS/CSS, static assets, and bundle analysis reports.
- [ ] The requested platform-specific package command (e.g. `pnpm run package:win`) completes successfully, if one was requested.
- [ ] The pull request targets the `dev` branch and follows Conventional Commits formatting.

## Next steps

- `add-host-manager` — the change this skill typically verifies before a PR
- `setup-toolbox-dev-env` — get `pnpm run dev` running for local iteration before this final check
- `docs/pptb-tools/toolbox-development/architecture/` — background on the three-bundle build and output structure
