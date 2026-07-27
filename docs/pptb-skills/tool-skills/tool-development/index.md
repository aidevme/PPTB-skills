---
title: tool-development
description: Entry point that routes a tool-development request to the specific skill it needs.
last_verified: 2026-07-27
---

# tool-development

This skill is the starting point for anyone building a PPTB tool. It doesn't scaffold or wire anything itself — it maps the request to whichever of the more specific tool-development skills actually applies, so a developer (or an agent) doesn't need to already know the catalog to get started.

**A PPTB tool is a web app (HTML/CSS/TypeScript) that declares itself through a `package.json` manifest and talks to the host exclusively through the `toolboxAPI`, `dataverseAPI`, and `powerplatformAPI` injected into its sandboxed iframe.**

## When to use it

- "Build a PPTB tool."
- "Develop a tool for Power Platform ToolBox."
- "Create a ToolBox plugin."
- "Help me build a tool that runs inside PPTB."
- Any tool-development request where it isn't yet clear which specific skill applies.

## Inputs

- What the request is actually asking for — a new project, a specific API integration, hardening, publishing, etc.
- Whether the request names a capability not covered by any listed skill, in which case the underlying API reference should be checked before improvising.

## What it does

1. Matches the request against a routing table covering scaffolding (`create-pptb-tool`), API integration (`add-toolbox-api`, `add-dataverse-api`, `add-powerplatform-api`, `add-file-system-api`, `add-events-api`, `add-settings-api`), configuration (`configure-csp`), hardening (`add-error-handling`), extensibility (`add-inter-tool-invocation`, `add-agent-integration`), and release (`validate-pptb-tool`, `publish-pptb-tool`).
2. Falls back to a fuller skills catalog reference when the compact routing table doesn't disambiguate a request.
3. Points to the underlying API reference docs when a request names a capability outside the existing skill set, rather than guessing.
4. Explains the typical build order so a multi-step request (e.g. "scaffold a tool that reads Dataverse and publishes it") is broken into the right sequence of skills instead of being treated as one undifferentiated task.

## Example

A request like "I want to build a PPTB tool that lists Dataverse accounts and lets the user export them to a file" routes to:

1. `create-pptb-tool` — scaffold the project and manifest.
2. `add-dataverse-api` — query accounts.
3. `add-file-system-api` — export to a file.
4. `add-error-handling` — wrap the calls.
5. `validate-pptb-tool` / `publish-pptb-tool` — ship it.

## Checklist it enforces

- [ ] The request is matched to a specific skill (or an ordered sequence of skills) rather than answered directly from general knowledge.
- [ ] Capabilities outside the routing table are checked against the API reference docs before improvising.
- [ ] Multi-step requests are broken into the typical build order rather than tackled as one undifferentiated task.

## Related

- [Tool Development](/pptb-tools/tool-development/) — the architecture/workflow reference this skill is built on
- [toolbox-development](/pptb-skills/toolbox-skills/) — the sibling entry point for contributors building the ToolBox host application itself
