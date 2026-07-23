---
title: validate-pptb-tool
description: Runs pptb-validate against a tool's package.json and reports errors, warnings, and exit status before publishing.
last_verified: 2026-07-22
---

# validate-pptb-tool

This skill runs local validation against a PPTB tool's `package.json` using the `pptb-validate` CLI (shipped with `@pptb/types`) and reports back exactly what would fail a registry review — before any npm version number gets consumed on a rejected publish. It installs the dependency and wires the `validate` script if either is missing, then runs and interprets the result.

**Run `pptb-validate` before every publish — it catches configuration issues early, reduces review rejections, and speeds up the registry review process.**

## When to use it

- "Validate my tool before I publish."
- "Check my package.json against the PPTB rules."
- "Why would the registry reject this tool?"
- "Add a validate script to package.json."
- As a required step before `publish-pptb-tool` runs, or in CI right after a build.

## Inputs

- The path to the tool's `package.json` (defaults to the project root).
- Whether `@pptb/types` is already installed as a dev dependency.
- Whether to run offline (skip URL reachability checks) or with full network checks.
- Whether output should be human-readable or JSON (for CI parsing).

## What it does

1. Checks whether `@pptb/types` is installed as a dev dependency; if not, runs `npm install --save-dev @pptb/types`.
2. Checks `package.json` for a `validate` script that runs `pptb-validate`; adds `"validate": "pptb-validate"` under `scripts` if missing.
3. Runs `npm run validate` (or `npx pptb-validate` if no script exists yet), optionally with `--skip-url-checks` for offline/faster runs or `--json` for CI-parseable output.
4. Parses the result against required manifest fields: `name`, `version`, `displayName`, `description`, `license`, `contributors`, `repository`, and the readme URL.
5. Flags any `license` value that isn't on the approved list (MIT, Apache-2.0, BSD variants, GPL versions, LGPL-3.0, ISC, AGPL-3.0-only).
6. Reports optional-field warnings (`icon`, `website`, `funding`, CSP exceptions, API requirements) separately from blocking errors.
7. Interprets the exit code: `0` means clean (warnings may still be present but don't block), `1` means at least one error must be fixed before publishing.

## Example

Before — `package.json` missing the validate script and a required field:

```json
{
  "name": "@my-org/record-picker",
  "version": "1.0.0",
  "main": "index.html"
}
```

Skill output:

```text
$ npm run validate

pptb-validate v1.x
✖ ERROR: "displayName" is required
✖ ERROR: "license" is required
⚠ WARNING: "icon" is not set — tool will use a default icon
Exit code: 1
```

After the skill adds the missing fields and the `validate` script:

```json
{
  "name": "@my-org/record-picker",
  "version": "1.0.0",
  "displayName": "Record Picker",
  "description": "Pick a Dataverse record from any entity.",
  "license": "MIT",
  "contributors": [{ "name": "Jane Doe", "url": "https://github.com/janedoe" }],
  "repository": "https://github.com/my-org/record-picker",
  "main": "index.html",
  "scripts": {
    "validate": "pptb-validate"
  }
}
```

```text
$ npm run validate
✓ All required fields present
Exit code: 0
```

## Checklist it enforces

- [ ] `@pptb/types` is installed as a dev dependency.
- [ ] A `validate` script exists in `package.json` and runs `pptb-validate`.
- [ ] `npm run validate` (or `npx pptb-validate`) exits with code `0` before publishing.
- [ ] All required manifest fields (`name`, `version`, `displayName`, `description`, `license`, `contributors`, `repository`, readme URL) are present.
- [ ] The declared `license` is one of the approved licenses.
- [ ] Reported warnings have been surfaced for review, even though they don't block a publish.

## Related

- [Local Validation](/pptb-tools/tool-development/local-validation/) — the reference this skill is built on
- [publish-pptb-tool](../publish-pptb-tool/) — runs this skill as its Step 3 before finalizing and publishing
- [add-error-handling](../add-error-handling/) — a common pre-publish companion pass
