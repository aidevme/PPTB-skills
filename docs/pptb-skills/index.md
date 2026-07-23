---
title: PPTB Skills Catalog
description: A catalog of proposed Claude Code skill specifications for automating PPTB tool and toolbox development.
last_verified: 2026-07-22
---

# PPTB Skills Catalog

> **Specification catalog, not shipped software.** This section documents **proposed Claude Code skill specifications** for the PPTB ecosystem — designs for AI-assistant skills that automate common tool-development and toolbox-development tasks. None of these are implemented yet; each page is a specification a future implementation would follow, describing what the skill should do, when it should trigger, and what it should produce.

Power Platform Toolbox (PPTB) has two distinct audiences, documented separately under [Tool Development](/pptb-tools/tool-development/) and [ToolBox Development](/pptb-tools/toolbox-development/):

- **Tool developers** build individual tools — sandboxed web apps that run inside the ToolBox host and talk to Dataverse and Power Platform through injected APIs.
- **ToolBox contributors** build the host application itself — the Electron shell, its main/renderer processes, and the API layer that bridges them.

Each audience repeats the same kinds of setup, wiring, and validation work across projects: scaffolding a manifest, adding an API call, configuring CSP, setting up the Electron build, wiring an IPC channel. This catalog specifies a Claude Code skill for each recurring task, grouped by audience.

## Skill groups

| Group | Audience | Description |
| --- | --- | --- |
| [Tool Skills](/pptb-skills/tool-skills/) | Tool developers | Skills that scaffold, wire, and validate an individual PPTB tool — manifest creation, ToolBox/Dataverse/PowerPlatform API integration, CSP configuration, error handling, inter-tool invocation, agent integration, validation, and publishing. |
| [ToolBox Skills](/pptb-skills/toolbox-skills/) | ToolBox contributors | Skills that support contributing to the ToolBox host application itself — environment setup, Electron/IPC wiring, and the build/release workflow. |

## How these skills fit together

Tool Skills and ToolBox Skills are independent groups aimed at different codebases and different contributors, but they share a common shape: each skill spec names concrete trigger phrases, the inputs it needs from the developer or the repo, the exact files and API calls it produces, and a checklist adapted from the corresponding PPTB reference page. A tool developer would typically reach for `create-pptb-tool` first, then layer in API and CSP skills as the tool's requirements grow, finishing with validation and publishing. A ToolBox contributor works from a separate set of skills scoped to the host application's own workflow. See each group's index page for the full skill list and links to individual specs.
