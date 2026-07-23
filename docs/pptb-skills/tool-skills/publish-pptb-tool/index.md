---
title: publish-pptb-tool
description: Walks a finished PPTB tool through manifest preparation, build, local validation, packaging, npm publish, and registry submission.
last_verified: 2026-07-22
---

# publish-pptb-tool

This skill drives a PPTB tool through the full publishing path — from a finalized `package.json` to a registry submission — running each of the seven documented steps in order and stopping to surface anything that needs the developer's attention (a missing required field, a failed build, a validation error) before moving on.

**Publishing is a seven-step path — prepare the manifest, build, validate locally, finalize the package, publish to npm, test the published version, then submit to the registry — and every step before registry submission is something you can verify yourself.**

## When to use it

- "Publish my tool."
- "Get this tool ready for the PPTB registry."
- "Walk me through publishing to npm and submitting to the toolbox."
- "I built my tool — what's left before it's public?"
- As the final step after `add-error-handling`, `validate-pptb-tool`, and any agent/inter-tool integration work is complete.

## Inputs

- The tool's `package.json` and current field values.
- The build tooling in use (no bundler + `shx`, Vite, or Webpack) — this determines how the icon reaches `dist/`.
- Whether this is a first-time npm publish (needs `npm login`) or a version bump on an existing package.
- The type of change since the last release (bug fix, new feature, breaking change) to pick the right version bump.
- Tags/categories for the registry submission (up to 3, from the approved list).

## What it does

1. **Prepares the manifest** — checks/fills required `package.json` fields: `name` (scoped, `@org/tool-name`), `displayName`, `description`, `main` (usually `index.html`), `icon` (an SVG path relative to `dist`, using `fill="currentColor"`), `contributors`, `license` (an approved license), `configurations` (repository URL, optional website/docs link), `cspExceptions`, and `features` (e.g. `multiConnection`, `minAPI`). Confirms the icon-copy mechanism matches the build tool: `shx` copy scripts (no bundler), `public/` folder (Vite), or `copy-webpack-plugin` (Webpack).
2. **Builds** — runs `npm run build` and verifies `dist/` contains `index.html`, the icon SVG at its declared path, all compiled JS/CSS, and any other required assets.
3. **Validates locally** — runs `npm run validate` or `npx pptb-validate`, fixes any errors (warnings are optional-but-recommended).
4. **Finalizes the package** — runs `npm run finalize-package` to prepare the correct file structure and dependencies for npm.
5. **Publishes to npm** — runs `npm login` if needed, then `npm publish --access public` for a scoped package (required for public scoped-package access) or `npm publish` for an unscoped one. Confirms with `npm view @your-org/your-tool-name` or the npmjs.com package page.
6. **Tests the published version** — opens Power Platform ToolBox's Debug section, installs the package by name via "Install from npm", and confirms it works from the published artifact, not just the local build.
7. **Submits to the registry** — directs the developer to the Tool Submission Form at `powerplatformtoolbox.com/submit-tool` (login required) with the npm package name and up to 3 tags from: Comparisons, Data, Development, Diagrams, Documentation, Environments, Migration, Solutions, Troubleshooting, Users & Security.
8. For version bumps on existing packages, picks the right Semantic Versioning command: `npm version patch` (bug fixes), `npm version minor` (new backward-compatible features), or `npm version major` (breaking changes).
9. Confirms README.md uses markdown only (no raw HTML — the registry doesn't render it for security reasons) and full URLs for external resources/images.

## Example

```bash
# Step 2: build
npm run build

# Step 3: validate
npm run validate
# ✓ All required fields present — exit code 0

# Step 4: finalize
npm run finalize-package

# Step 5: publish (scoped package)
npm publish --access public
npm view @my-org/record-picker
```

Registry submission fields:

```text
npm Package Name: @my-org/record-picker
Tags/Categories:  Data, Development
```

## Checklist it enforces

- [ ] `package.json` has all required fields: `name`, `version`, `displayName`, `description`, `main`, `icon`, `contributors`, `license`.
- [ ] The icon is present in `dist/` at the path referenced by `package.json`, using `fill="currentColor"`.
- [ ] `npm run build` completes and `dist/` contains everything needed to run the tool.
- [ ] `npm run validate` / `pptb-validate` passes with no errors.
- [ ] `npm run finalize-package` has been run.
- [ ] The package is published to npm (`npm view` confirms it) and reinstalled/tested from npm via ToolBox's Debug > Install from npm flow.
- [ ] The Tool Submission Form is completed with up to 3 relevant tags.
- [ ] README.md uses markdown only (no raw HTML) and full URLs for external resources.

## Related

- [Publishing Tools](/pptb-tools/tool-development/publishing-tools/) — the reference this skill is built on
- [validate-pptb-tool](../validate-pptb-tool/) — runs as this skill's Step 3
- [add-error-handling](../add-error-handling/) — publishing best practices call for "proper error handling," worth applying before this skill runs
