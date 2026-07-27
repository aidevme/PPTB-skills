---
name: validate-pptb-tool
description: Runs and interprets `pptb-validate` against a PPTB tool's `package.json` manifest before publishing. Use when asked to "validate my PPTB tool", "run pptb-validate", "check my manifest before publishing", "why is my tool failing review", or as the step right before `publish-pptb-tool`.
---

# Validate PPTB Tool

`pptb-validate`, included with `@pptb/types`, checks a tool's `package.json` against the official ToolBox review rules before it's submitted to the registry. Running it locally catches manifest problems before they cost an npm version bump or a rejected submission — this skill wires it up and interprets its output.

**Run `pptb-validate` before every publish — a clean run (exit code `0`) is a prerequisite for `publish-pptb-tool`, not an optional nicety.**

## Step 1: Install and wire up the script

Confirm `@pptb/types` is a dev dependency (it ships the `pptb-validate` binary):

```bash
npm install --save-dev @pptb/types
```

Add a `validate` script to `package.json` rather than expecting the developer to remember the raw command:

```json
{
  "scripts": {
    "validate": "pptb-validate"
  }
}
```

## Step 2: Run it

```bash
npm run validate
```

Equivalent alternatives: `npx pptb-validate`, or pointing it at a specific manifest path. Two CLI options matter beyond the default run:

| Option | Effect |
| --- | --- |
| `--skip-url-checks` | Disables URL reachability validation — use for offline runs or faster local iteration |
| `--json` | Outputs results as JSON — use this in CI pipelines instead of parsing human-readable output |

## Step 3: Interpret the result

- **Exit code `0`** — validation passed. This is the bar `publish-pptb-tool` requires before publishing.
- **Exit code `1`** — at least one error. Fix every reported error; don't proceed to publishing with a non-zero exit code.
- **Warnings** — don't fail the run (exit code stays `0` if there are no separate errors), but review them anyway; they flag recommended-but-not-required fields.

`pptb-validate` checks required fields — `name`, `version`, `displayName`, `description`, `license`, `contributors`, `repository`, and the readme URL — plus optional fields like `icon`, `website`, `funding`, `cspExceptions`, and `features` (API requirements). Approved licenses are `MIT`, `Apache-2.0`, BSD variants, GPL versions, `LGPL-3.0`, `ISC`, and `AGPL-3.0-only` — anything else is a validation error, not a warning.

## Step 4: Fix errors at the source, not by suppressing the check

If validation reports a missing or malformed field, fix it in `package.json` directly (see `create-pptb-tool` for the required-field list and `configure-csp` for `cspExceptions` shape) rather than reaching for `--skip-url-checks` to make an error disappear — that flag only skips URL reachability checks, it doesn't fix an actually-invalid manifest.

## Checklist

- [ ] `@pptb/types` is installed as a dev dependency.
- [ ] A `validate` script exists in `package.json` and runs `pptb-validate`.
- [ ] `npm run validate` (or `npx pptb-validate`) exits with code `0` before publishing.
- [ ] All required manifest fields (`name`, `version`, `displayName`, `description`, `license`, `contributors`, `repository`, readme URL) are present.
- [ ] The declared `license` is one of the approved licenses.
- [ ] Reported warnings have been reviewed, even though they don't block a publish.

## Next steps

- `create-pptb-tool` — the manifest this skill validates
- `configure-csp` — fix `cspExceptions` shape errors reported by validation
- `publish-pptb-tool` — the step that follows a clean `pptb-validate` run
