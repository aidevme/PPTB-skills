---
title: toolbox-development
description: Entry point that routes a ToolBox host contribution request to the specific skill it needs.
last_verified: 2026-07-27
---

# toolbox-development

This skill is the starting point for anyone contributing to the Power Platform ToolBox host application itself — the Electron shell that loads and runs tools — as distinct from building a tool that runs inside it. It doesn't set up an environment, scaffold a manager, or build anything itself; it identifies which of the more specific toolbox-development skills the request actually needs.

**The host is split into a main process, a renderer process, and an API layer; every tool runs inside a sandboxed iframe with no direct access to Node.js or Electron APIs, communicating only through `toolboxAPI`/`toolboxAPIBridge.js` — a change to host behavior almost always means touching one of these three layers, never exposing something to the iframe directly.**

## When to use it

- "Contribute to the ToolBox host."
- "Set up the ToolBox dev environment."
- "Add a new manager to the ToolBox host."
- "Package a ToolBox build."
- "Work on the Electron app."
- Any request about the host application's own codebase where it isn't yet clear which specific skill applies.

## Inputs

- What the request is actually asking for — getting a local environment running, adding new main-process capability, or verifying/producing a build.
- Whether the request is about the host's internal architecture rather than a task to perform, in which case the architecture reference should be checked before improvising.

## What it does

1. Matches the request against a routing table covering environment setup (`setup-toolbox-dev-env`), extending main-process capability (`add-host-manager`), and build/release verification (`package-toolbox`).
2. Falls back to a fuller skills catalog reference when the compact routing table doesn't disambiguate a request.
3. Points to the architecture reference docs when a request is about how the host is structured internally, rather than a task to perform.
4. Explains the typical contributor workflow so a multi-step change (e.g. "add a new manager and get it ready for a PR") is broken into the right sequence of skills instead of being treated as one undifferentiated task.

## Example

A request like "I want to add environment-variable support to the ToolBox host and open a PR" routes to:

1. `setup-toolbox-dev-env` — get `pnpm run dev` running locally, if not already done.
2. `add-host-manager` — scaffold the new manager following the existing pattern.
3. `package-toolbox` — verify lint/build/package before opening the PR.

## Checklist it enforces

- [ ] The request is matched to a specific skill (or an ordered sequence of skills) rather than answered directly from general knowledge.
- [ ] Architecture questions are checked against the architecture reference docs before improvising.
- [ ] Multi-step contributions are broken into the typical contributor workflow rather than tackled as one undifferentiated task.

## Related

- [ToolBox Development](/pptb-tools/toolbox-development/) — the architecture/workflow reference this skill is built on
- [tool-development](/pptb-skills/tool-skills/) — the sibling entry point for building a tool that runs inside the ToolBox host, rather than the host itself
