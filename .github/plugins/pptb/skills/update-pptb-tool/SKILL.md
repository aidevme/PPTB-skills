---
name: update-pptb-tool
description: Entry point for modifying an existing PPTB tool — confirms the project really is an already-scaffolded tool, then routes the change to the right skill (a new API integration, a version bump, a dependency upgrade, or a manifest-only edit). Use when asked to "update my PPTB tool", "add X to my existing tool", "bump the version before republishing", "upgrade @pptb/types", or any change to a tool that's already been scaffolded — the counterpart to `create-pptb-tool` for tools that already exist.
---

# Update PPTB Tool

Once a PPTB tool has been scaffolded with `create-pptb-tool`, most further work is a modification to something that already exists rather than a fresh scaffold. This skill is the entry point for that case: confirm the project really is an existing tool, then route the specific change to the skill that actually handles it.

**Never re-run `create-pptb-tool`'s scaffolding against an existing project — it will overwrite manifest fields and starter files the developer has already customized. Confirm the project is an existing tool first, then route to the specific skill the change needs.**

## Step 1: Confirm this is an existing tool

- `package.json` exists and already has `displayName`, `main`, and `icon` fields.
- `@pptb/types` is listed in `devDependencies`.

If both are true, this is an existing tool — continue below. If either is missing, this isn't actually an update; hand off to `create-pptb-tool` instead.

## Step 2: Identify the kind of update

| The change is about... | Reach for |
| --- | --- |
| Adding a new host/Dataverse/PowerPlatform API integration, CSP, error handling, inter-tool invocation, or agent integration | The matching skill from `tool-development`'s routing table |
| Bumping the version before republishing | `npm version patch\|minor\|major`, then `validate-pptb-tool` and `publish-pptb-tool` |
| Upgrading `@pptb/types` to pick up new API surface | `npm install --save-dev @pptb/types@latest`, then re-check `features.minAPI` against whatever new methods are now used |
| Editing manifest-only fields (icon, description, license, contributors, `configurations`) | Edit `package.json` directly — see `create-pptb-tool`'s manifest reference for field constraints |
| Publishing an update | `validate-pptb-tool`, then `publish-pptb-tool` |

## Step 3: Re-validate after the change

Run `validate-pptb-tool` (`pptb-validate`) after any manifest-affecting change — a version bump, a dependency upgrade, or a new `features`/`cspExceptions` entry — before publishing.

## Checklist

- [ ] The project was confirmed as an existing tool (`displayName`/`main`/`icon` in `package.json`, `@pptb/types` in `devDependencies`) before making changes — not re-scaffolded.
- [ ] The change was routed to the specific skill that handles it, rather than hand-rolled.
- [ ] `validate-pptb-tool` was re-run after any manifest-affecting change.

## Next steps

- `tool-development` — the full routing table for capability-specific changes
- `create-pptb-tool` — manifest field reference and required-fields list
- `validate-pptb-tool` / `publish-pptb-tool` — close out the update before it ships
