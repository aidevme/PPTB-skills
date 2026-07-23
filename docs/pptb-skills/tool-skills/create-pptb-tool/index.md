---
title: create-pptb-tool
description: Scaffolds a new PPTB tool project with a valid package.json manifest and local validation wired up.
last_verified: 2026-07-22
---

# create-pptb-tool

This skill automates the first step of building a PPTB tool: producing a `package.json` manifest that satisfies every field the ToolBox host requires, plus the `@pptb/types` dev dependency and `pptb-validate` script a developer needs before their first publish. A developer reaches for it at the very start of a new tool project, instead of hand-assembling the manifest from memory and re-discovering which fields are mandatory.

**The skill must not produce a manifest missing any of `name`, `version`, `displayName`, `description`, `main`, `icon`, `license`, `contributors`, or `configurations` — the ToolBox host refuses to load a tool missing any of them.**

## When to use it

- "Scaffold a new PPTB tool"
- "Create a new tool project for ToolBox"
- "Set up the package.json for my PPTB tool"
- "I'm starting a new PPTB tool called ___"
- Starting a fresh repository intended to become a ToolBox tool, with no existing manifest

## Inputs

- Tool name (used to derive the scoped npm package `name`, e.g. `@myorg/my-tool`) and `displayName`
- Short `description` of what the tool does
- `license` — one of the approved identifiers (`MIT`, `Apache-2.0`, `BSD-2-Clause`, `BSD-3-Clause`, `GPL-2.0`, `GPL-3.0`, `LGPL-3.0`, `ISC`, `AGPL-3.0-only`)
- Contributor name(s) and optional URL(s)
- Source repository URL (for `configurations.repository`)
- Whether the tool needs a second Dataverse connection (`features.multiConnection`)
- Entry-point file name (defaults to `index.html`) and icon path (defaults to `icons/tool.svg`)

## What it does

1. Generates `package.json` at the project root with the required top-level fields: `name`, `version` (`"1.0.0"` default), `displayName`, `description`, `main`, `icon`, `license`, `contributors`, `configurations`.
2. Populates `configurations.repository` (required) and, when provided, `configurations.website` and `configurations.readmeUrl`.
3. Sets `icon` to an SVG path relative to the `dist` root and reminds the developer to use `fill="currentColor"` in the SVG so it adapts to light/dark themes — `iconURL` under `configurations` is not supported.
4. Adds `features.multiConnection` (`"optional"` or `"required"`) only when the developer indicated the tool needs a second connection, and omits the `features` object entirely otherwise.
5. Installs `@pptb/types` as a dev dependency and adds a `"validate": "pptb-validate"` script to `package.json`, per the local-validation workflow.
6. Scaffolds the entry-point file (`main`) and an `icons/` folder with a placeholder SVG using `fill="currentColor"`.
7. Runs `npm run validate` (or `npx pptb-validate`) once scaffolding is complete and surfaces any errors before the developer starts writing tool code.

## Example

Before: an empty project directory.

After (`package.json`):

```json
{
  "name": "@myorg/my-awesome-tool",
  "version": "1.0.0",
  "displayName": "My Awesome Tool",
  "description": "Manage Dataverse solutions across environments with ease.",
  "main": "index.html",
  "icon": "icons/tool.svg",
  "license": "MIT",
  "contributors": [{ "name": "Jane Dev", "url": "https://janedev.com" }],
  "configurations": {
    "repository": "https://github.com/myorg/my-awesome-tool"
  },
  "devDependencies": {
    "@pptb/types": "^1.0.0"
  },
  "scripts": {
    "validate": "pptb-validate"
  }
}
```

## Checklist it enforces

- [ ] `name`, `version`, `displayName`, `description`, `main`, `icon`, `license`, `contributors`, and `configurations` are all present.
- [ ] `license` uses one of the approved identifiers.
- [ ] Each entry in `contributors` has at least a `name`.
- [ ] `configurations.repository` is populated with a real repository URL.
- [ ] `icon` is an SVG path relative to `dist`, using `fill="currentColor"`.
- [ ] `@pptb/types` is installed as a dev dependency and a `validate` script runs `pptb-validate`.
- [ ] `npm run validate` exits with code `0` before the developer starts writing tool code.

## Related

- [Package Manifest](/pptb-tools/tool-development/package-manifest/) — the manifest schema this skill is built on
- [Local Validation](/pptb-tools/tool-development/local-validation/) — the `pptb-validate` workflow this skill wires up
- Related skills: `../validate-pptb-tool/`, `../configure-csp/`
