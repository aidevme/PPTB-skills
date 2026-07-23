---
title: Local Validation
description: How to validate a PPTB tool's package.json locally with pptb-validate before publishing.
source: https://docs.powerplatformtoolbox.com/tool-development/validation
last_verified: 2026-07-22
---

# Local Validation

The `pptb-validate` CLI, included with `@pptb/types`, lets you validate your tool's `package.json` against the official Power Platform ToolBox review rules before you publish to npm. Running it locally catches manifest problems before they cost you an npm version bump or a rejected submission.

**Run `pptb-validate` before every publish — it catches configuration issues early, reduces review rejections, and speeds up the registry review process.**

## Key purpose

Running validation locally helps you by:

- Identifying configuration issues early, without consuming npm version numbers on a rejected publish.
- Reducing review rejections caused by setup problems.
- Accelerating the review timeline once you do submit.

## Installation and setup

Install `@pptb/types` as a development dependency:

```bash
npm install --save-dev @pptb/types
```

The `pptb-validate` binary is then available in `node_modules/.bin/`.

## Usage

The recommended approach is to add a `validate` script to `package.json`:

```json
{
  "scripts": {
    "validate": "pptb-validate"
  }
}
```

Then run it with:

```bash
npm run validate
```

Alternatively, run it directly with `npx pptb-validate`, or point it at a specific file path.

## CLI options

| Option | Effect |
| --- | --- |
| `--skip-url-checks` | Disables URL reachability validation, for offline or faster runs |
| `--json` | Outputs results as JSON, for CI pipeline integration |
| `--help` / `-h` | Displays help information |

## Validation rules

`pptb-validate` checks required fields — `name`, `version`, `displayName`, `description`, `license`, `contributors`, `repository`, and the readme URL — as well as optional fields such as `icon`, `website`, `funding`, CSP exceptions, and API requirements.

Approved licenses are: MIT, Apache-2.0, BSD variants, GPL versions, LGPL-3.0, ISC, and AGPL-3.0-only.

## Exit behavior

A successful validation run returns exit code `0`. Any errors produce exit code `1`. Warnings alone do not cause a non-zero exit — treat them as recommended fixes, not blockers.

## Checklist

- [ ] `@pptb/types` is installed as a dev dependency.
- [ ] A `validate` script exists in `package.json` and runs `pptb-validate`.
- [ ] `npm run validate` (or `npx pptb-validate`) exits with code `0` before publishing.
- [ ] All required manifest fields (`name`, `version`, `displayName`, `description`, `license`, `contributors`, `repository`, readme URL) are present.
- [ ] The declared `license` is one of the approved licenses.
- [ ] Reported warnings have been reviewed, even though they don't block a publish.

## Related links

- [Local Tool Validation (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/validation)
- [Tool Development](/pptb-tools/tool-development/)
- [Publishing Tools](/pptb-tools/tool-development/publishing-tools/)
