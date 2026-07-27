---
name: publish-pptb-tool
description: Finalizes, builds, and publishes a PPTB tool to npm, then submits it to the ToolBox registry. Use when asked to "publish my tool", "release my PPTB tool", "submit my tool to the registry", "how do I publish to npm and ToolBox", or when a tool has passed local validation and is ready to ship.
---

# Publish PPTB Tool

Publishing is a seven-step path from a locally-working tool to a registry-listed one: prepare the manifest, build, validate locally, finalize the package, publish to npm, test the published version, then submit to the registry. Every step before registry submission is verifiable by the developer themselves — this skill walks through each in order.

**Don't skip straight to `npm publish` — build, `pptb-validate`, and testing the actual published package (not just the local build) all come first, and each catches a different class of problem before it reaches a reviewer or a user.**

## Prerequisites

Before starting, confirm the tool:

- Builds successfully without errors.
- Has been tested in local debug mode.
- Follows the conventions from `create-pptb-tool` and whichever API/CSP/error-handling skills apply.
- Has a README.md — the registry doesn't render raw HTML in it, so use markdown-only syntax and full URLs for external resources (no relative links to assets outside the package).

## Step 1: Prepare the manifest

Confirm `package.json` has every required field: `name` (scoped, `@org/tool-name`), `displayName`, `description` (1–2 sentences), `main` (usually `index.html`), `icon` (SVG path relative to `dist`, `fill="currentColor"`), `contributors`, `license` (an approved identifier), `configurations` (repository URL, optionally website/readme), `cspExceptions` if the tool reaches external domains (see `configure-csp`), and `features` if the tool needs `multiConnection` or a `minAPI` floor.

Make sure the icon actually lands in `dist/` at build time — the mechanism depends on the bundler:

- **No bundler** — `shx` copy scripts (`npm install --save-dev shx`) to copy HTML/CSS/icon into `dist`.
- **Vite** — place the icon under `public/`; Vite copies it to `dist` automatically. Match the `icon` field in `package.json` to that `public` folder structure.
- **Webpack** — `copy-webpack-plugin` to copy `public/` into `dist`.

## Step 2: Build

```bash
npm run build
```

Verify `dist/` actually contains `index.html`, the icon SVG at the path `package.json` references, all compiled JS/CSS, and any other required assets — don't assume a successful exit code means everything landed correctly.

## Step 3: Validate locally

```bash
npm run validate
```

(or `npx pptb-validate` — see `validate-pptb-tool`.) Fix every reported error before continuing; warnings are recommended fixes, not blockers.

## Step 4: Finalize the package

```bash
npm run finalize-package
```

This prepares the package with the correct file structure and dependencies for publishing.

## Step 5: Publish to npm

First time publishing: `npm login`. Then:

```bash
npm publish --access public
```

`--access public` is required for a scoped package (`@org/tool-name`) to be publicly accessible — an unscoped package just needs `npm publish`. Confirm the publish actually landed:

```bash
npm view @your-org/your-tool-name
```

## Step 6: Test the published version, not just the local build

1. Open Power Platform ToolBox.
2. Go to the Debug section → "Install from npm".
3. Enter the published package name and install it.
4. Test thoroughly from the published package — a local `dist/` that worked doesn't guarantee the published tarball is identical (missing `files` entries are a common gap; double-check anything the tool depends on, like `pptb.config.json` for inter-tool invocation, is actually included).

## Step 7: Submit to the ToolBox registry

Visit the Tool Submission Form (login required) at `powerplatformtoolbox.com/submit-tool` with the npm package name and up to 3 tags from: Comparisons, Data, Development, Diagrams, Documentation, Environments, Migration, Solutions, Troubleshooting, Users & Security.

Automated checks confirm the npm package exists and is accessible, the metadata is appropriate, the license is acceptable, there are no known vulnerabilities, and the package structure is correct. A manual review by maintainers follows (typically 48–72 hours), covering security, quality, functionality, and documentation.

## Versioning updates after the first publish

Follow semver strictly:

| Change type | Bump | Command |
| --- | --- | --- |
| Bug fix | Patch (`1.0.X`) | `npm version patch` |
| Backward-compatible feature | Minor (`1.X.0`) | `npm version minor` |
| Breaking change | Major (`X.0.0`) | `npm version major` |

An update is: bump the version, rebuild, republish to npm. The ToolBox registry syncs from npm automatically and users get update notifications — there's no separate "resubmit to registry" step for a version bump.

## Troubleshooting

- **"You must be logged in to publish packages"** — `npm login`, then retry.
- **"Package name too similar to existing package"** — pick a more distinct name, or use scoped naming.
- **Tool not appearing in registry** — confirm automated validation passed, check for reviewer feedback on the submission, and confirm the npm package is actually publicly accessible.
- **Users reporting issues post-publish** — reproduce in debug mode, fix locally, bump the version, republish, and notify users in the issue thread.

## Checklist

- [ ] `package.json` has all required fields: `name`, `version`, `displayName`, `description`, `main`, `icon`, `contributors`, `license`.
- [ ] The icon is present in `dist/` at the path referenced by `package.json`, using `fill="currentColor"`.
- [ ] `npm run build` completes and `dist/` contains everything needed to run the tool.
- [ ] `npm run validate` / `pptb-validate` passes with no errors.
- [ ] `npm run finalize-package` has been run.
- [ ] The package is published to npm (`npm view` confirms it) and reinstalled/tested from npm via ToolBox's Debug → Install from npm flow.
- [ ] The Tool Submission Form is completed with up to 3 relevant tags.
- [ ] README.md uses markdown only (no raw HTML) and full URLs for external resources.

## Next steps

- `create-pptb-tool` / `configure-csp` — the manifest fields this skill's Step 1 depends on
- `validate-pptb-tool` — the detailed CLI reference for Step 3
- `add-error-handling` — a pre-publish hardening pass, ideally done before Step 1 here
