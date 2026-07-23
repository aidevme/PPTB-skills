---
title: Publishing Tools
description: How to package a finished PPTB tool, publish it to npm, and submit it to the ToolBox registry.
source: https://docs.powerplatformtoolbox.com/tool-development/publishing
last_verified: 2026-07-22
---

# Publishing Tools

Once you've tested your tool locally and are ready to share it with the community, this page walks through publishing it to npm and submitting it to the ToolBox registry.

**Publishing is a seven-step path — prepare the manifest, build, validate locally, finalize the package, publish to npm, test the published version, then submit to the registry — and every step before registry submission is something you can verify yourself.**

## Prerequisites

Before publishing, make sure your tool:

- Builds successfully without errors.
- Has been tested in local debug mode.
- Passes local validation with `pptb-validate`.
- Follows the Tool Development Guide.
- Has complete `package.json` metadata.
- Has an appropriate license (open source recommended).
- Has documentation (a README.md).

The registry does not support direct HTML inside the README, for security reasons — use markdown syntax for images and links, and use full URLs for external resources.

## Step 1: Prepare your package

Update `package.json` with the required fields:

- `name` — scoped package name (`@org/tool-name`).
- `displayName` — human-readable name shown in ToolBox.
- `description` — a brief 1-2 sentence description.
- `main` — entry point file, usually `index.html`.
- `icon` — an SVG path relative to the `dist` root (e.g., `icons/test.svg`), using `fill="currentColor"` so it adapts to the toolbox's theme.
- `contributors` — an array of authors with names and URLs.
- `license` — an approved open-source license: MIT, Apache-2.0, a BSD variant, a GPL variant, LGPL-3.0, ISC, or AGPL-3.0-only.
- `configurations` — the repository URL, and optionally a website/documentation link.
- `cspExceptions` — Content Security Policy exceptions, if needed (see [CSP Configuration](/pptb-tools/tool-development/csp-configuration/)).
- `features` — special features such as `multiConnection` or a `minAPI` requirement.

The icon file must end up in `dist/` after building. How you get it there depends on your build setup:

- **No bundler** — use [`shx`](https://www.npmjs.com/package/shx) for cross-platform copying: `npm install --save-dev shx`, then configure build scripts to copy HTML, CSS, and icon files into `dist`.
- **Vite** — place the icon in `public/`; Vite copies it to `dist` automatically at build time. Update the `icon` field in `package.json` to match the `public` folder structure (e.g., `icon/test.svg`).
- **Webpack** — use `copy-webpack-plugin` (`npm install --save-dev copy-webpack-plugin`) to copy the `public` folder into `dist`.

## Step 2: Build your tool

Run:

```bash
npm run build
```

Verify the `dist/` directory contains:

- `index.html` (the entry point)
- The icon SVG at the path referenced in `package.json`
- All compiled JavaScript/CSS files
- Any other required assets

## Step 3: Validate locally

Run:

```bash
npm run validate
```

or

```bash
npx pptb-validate
```

to check `package.json` against the official review rules. Fix any errors before continuing — warnings indicate optional-but-recommended fields. See [Local Validation](/pptb-tools/tool-development/local-validation/) for CLI options.

## Step 4: Finalize package

Run:

```bash
npm run finalize-package
```

to prepare the package for npm with the correct file structure and dependencies.

## Step 5: Publish to npm

If this is your first time publishing, run `npm login` to create/sign in to an npm account.

Publish with:

```bash
npm publish --access public
```

for a scoped package (`--access public` is required for scoped packages to be publicly accessible), or:

```bash
npm publish
```

for an unscoped package.

Verify the publish with:

```bash
npm view @your-org/your-tool-name
```

or by visiting the package's page on npmjs.com.

## Step 6: Test the published version

Before submitting to the registry:

1. Open Power Platform ToolBox.
2. Navigate to the Debug section.
3. In the "Install from npm" section, enter your package name and select **Install**.
4. Test thoroughly to confirm everything works from the published package, not just your local build.

## Step 7: Submit to the ToolBox registry

Visit the Tool Submission Form (login required) at `powerplatformtoolbox.com/submit-tool` and provide:

- **npm Package Name** — your published npm package name.
- **Tags/Categories** — up to 3, chosen from Comparisons, Data, Development, Diagrams, Documentation, Environments, Migration, Solutions, Troubleshooting, or Users & Security.

Automated validation checks:

- The npm package exists and is accessible.
- The package contains appropriate metadata.
- The license is appropriate (open source preferred).
- There are no known security vulnerabilities.
- The package structure is correct.

A manual review by maintainers follows, examining security, quality, functionality, and documentation. Review typically takes 48-72 hours.

## Versioning and updates

Follow Semantic Versioning:

| Change type | Version bump | Command |
| --- | --- | --- |
| Bug fixes | Patch (1.0.X) | `npm version patch` |
| New backward-compatible features | Minor (1.X.0) | `npm version minor` |
| Breaking changes | Major (X.0.0) | `npm version major` |

Publishing an update means bumping the version, building, and publishing to npm again. The ToolBox registry automatically syncs with npm, and users receive update notifications.

## Best practices

**Before publishing:**

- Test thoroughly in debug mode.
- Run `pptb-validate` and fix all errors.
- Write a comprehensive README with usage instructions.
- Include screenshots or demo GIFs.
- Document all features and limitations.
- Add proper error handling.
- Follow UI/UX guidelines.

**After publishing:**

- Monitor GitHub issues for bug reports.
- Respond to user feedback promptly.
- Keep dependencies up to date.
- Maintain a CHANGELOG.
- Provide migration guides for breaking changes.
- Follow semantic versioning strictly.

**Security:**

- Never include hardcoded credentials or API keys.
- Validate all user inputs.
- Use HTTPS for all external API calls.
- Don't access sensitive system resources.
- Follow the principle of least privilege.

## Troubleshooting

### `npm publish` fails

- "You must be logged in to publish packages" — run `npm login` and retry.
- "Package name too similar to existing package" — choose a more unique name, or use scoped naming.

### Tool not appearing in registry

- Check that automated validation passed.
- Review the submission for reviewer feedback.
- Verify the npm package is publicly accessible.
- Confirm `package.json` has all required fields.

### Users reporting issues

1. Reproduce the issue in debug mode.
2. Fix it locally.
3. Bump the version number.
4. Publish the update to npm.
5. Notify users in the issue thread.

## Support

- GitHub Discussions — ask the community.
- GitHub Issues — report problems.
- The full Tool Development Guide — for reference documentation.

## Checklist

- [ ] `package.json` has all required fields: `name`, `version`, `displayName`, `description`, `main`, `icon`, `contributors`, `license`.
- [ ] The icon is present in `dist/` at the path referenced by `package.json`, using `fill="currentColor"`.
- [ ] `npm run build` completes and `dist/` contains everything needed to run the tool.
- [ ] `npm run validate` / `pptb-validate` passes with no errors.
- [ ] `npm run finalize-package` has been run.
- [ ] The package is published to npm (`npm view` confirms it) and reinstalled/tested from npm via ToolBox's Debug > Install from npm flow.
- [ ] The Tool Submission Form is completed with up to 3 relevant tags.
- [ ] README.md uses markdown only (no raw HTML) and full URLs for external resources.

## Related links

- [Publishing Your Tool (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/publishing)
- [Tool Development](/pptb-tools/tool-development/)
- [Local Validation](/pptb-tools/tool-development/local-validation/)
- [CSP Configuration](/pptb-tools/tool-development/csp-configuration/)
