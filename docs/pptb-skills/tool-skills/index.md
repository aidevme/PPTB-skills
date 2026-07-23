---
title: Tool Skills
description: Overview of the Claude Code skill specifications for building an individual PPTB tool.
last_verified: 2026-07-22
---

# Tool Skills

Tool Skills cover the recurring work of building a single PPTB tool: scaffolding the project and manifest, wiring up the ToolBox/Dataverse/PowerPlatform APIs, configuring CSP, handling errors, invoking other tools, integrating with AI agents, validating the manifest, and publishing to the registry. Each skill below is a full specification — trigger phrases, required inputs, exact actions, and a verification checklist — grounded in the corresponding [Tool Development](/pptb-tools/tool-development/) reference page.

## All tool skills

| Skill | Description |
| --- | --- |
| [create-pptb-tool](/pptb-skills/tool-skills/create-pptb-tool/) | Scaffolds a new PPTB tool project with a valid `package.json` manifest and local validation wired up. |
| [add-toolbox-api](/pptb-skills/tool-skills/add-toolbox-api/) | Wires up `window.toolboxAPI` calls — connections, utils, terminal, invocation, tool context — into a tool's code. |
| [add-dataverse-api](/pptb-skills/tool-skills/add-dataverse-api/) | Adds `window.dataverseAPI` CRUD, query, and metadata calls, keeping metadata changes paired with `publishCustomizations()`. |
| [add-powerplatform-api](/pptb-skills/tool-skills/add-powerplatform-api/) | Wires up `window.powerplatformAPI` namespace calls and the Entra app registration prerequisites they depend on. |
| [configure-csp](/pptb-skills/tool-skills/configure-csp/) | Adds and scopes `cspExceptions` entries in the manifest for external domains a tool needs to reach. |
| [add-error-handling](/pptb-skills/tool-skills/add-error-handling/) | Adds consistent error handling and user-facing notifications around ToolBox/Dataverse/PowerPlatform API calls. |
| [validate-pptb-tool](/pptb-skills/tool-skills/validate-pptb-tool/) | Runs and interprets `pptb-validate` against the manifest before publishing. |
| [add-inter-tool-invocation](/pptb-skills/tool-skills/add-inter-tool-invocation/) | Wires up `toolboxAPI.invocation` so one tool can launch another and exchange data. |
| [add-agent-integration](/pptb-skills/tool-skills/add-agent-integration/) | Integrates a tool with AI-assistant/agent workflows exposed by ToolBox. |
| [publish-pptb-tool](/pptb-skills/tool-skills/publish-pptb-tool/) | Finalizes, builds, and submits a tool to the PPTB registry via the Tool Submission Form. |

`create-pptb-tool`, `add-toolbox-api`, `add-dataverse-api`, `add-powerplatform-api`, and `configure-csp` have full specs in this section. `add-error-handling`, `validate-pptb-tool`, `add-inter-tool-invocation`, `add-agent-integration`, and `publish-pptb-tool` are specified alongside them — see the full catalog for each skill's page.

## How these skills fit together

A typical tool build starts with `create-pptb-tool` to scaffold the manifest and project, then layers in whichever of `add-toolbox-api`, `add-dataverse-api`, and `add-powerplatform-api` the tool's functionality requires. `configure-csp` runs whenever any of those integrations reach an external domain outside Dataverse. `add-error-handling` wraps the resulting API calls, `add-inter-tool-invocation` and `add-agent-integration` add cross-tool and AI-assistant behavior where needed, and `validate-pptb-tool` plus `publish-pptb-tool` close out the workflow before the tool reaches the registry.
