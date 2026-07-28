---
name: tool-development
description: Entry point for building a PPTB tool — a web app that runs inside the Power Platform ToolBox host and talks to Dataverse/Power Platform through injected APIs. Use when asked to "build a PPTB tool", "develop a tool for Power Platform ToolBox", "create a ToolBox plugin", "help me build a tool that runs inside PPTB", or any tool-development request where it isn't yet clear which specific skill applies — this skill routes to the right one. Not for building the ToolBox host application itself (see `toolbox-development`).
---

# Tool Development

Power Platform ToolBox (PPTB) is a secure, extensible platform for creating custom tools as web applications. Tools run in sandboxed iframes with controlled API access rather than as arbitrary desktop code — the host brokers access to Dataverse, Power Platform services, and local resources on the tool's behalf. This skill is the starting point for anyone building a PPTB tool: it doesn't scaffold or wire anything itself, it identifies which of the more specific tool-development skills the request actually needs.

**A PPTB tool is a web app (HTML/CSS/TypeScript) that declares itself through a `package.json` manifest and talks to the host exclusively through the `toolboxAPI`, `dataverseAPI`, and `powerplatformAPI` injected into its sandboxed iframe — it never gets arbitrary filesystem or OS access outside what those APIs broker.**

## First decision: create-pptb-tool or update-pptb-tool?

Before routing anywhere else, determine whether the working directory already contains a PPTB tool:

- Check whether `package.json` exists and already has `displayName`, `main`, and `icon` fields, and whether `@pptb/types` is listed in `devDependencies`.
- **If both are true** — this is an existing tool. Hand off to `update-pptb-tool`, which confirms the project and routes the specific change (a new capability, a version bump, a dependency upgrade, a manifest edit) to the skill that handles it.
- **Otherwise** — this is a new tool. Reach for `create-pptb-tool` first; every other skill in the table below assumes a scaffolded project already exists.

Never jump straight to a capability skill (`add-toolbox-api`, `configure-csp`, etc.) without first going through this decision — `create-pptb-tool` re-scaffolding an existing project overwrites customized manifest fields and starter files, and `update-pptb-tool` catches that before it happens.

## Which skill do I need?

| The request is about... | Reach for | Covers |
| --- | --- | --- |
| Starting a brand-new tool project | `create-pptb-tool` | `yo pptb` generator, `package.json` manifest, `@pptb/types`, starter `index.html`/`app.ts` |
| Modifying a tool that's already scaffolded | `update-pptb-tool` | Confirms the existing project, routes the change (version bump, dependency upgrade, new capability, manifest edit) |
| Reading the active connection, notifications, clipboard, theme, terminal sessions, direct inter-tool `launchTool()` | `add-toolbox-api` | `window.toolboxAPI` — connections, utils, terminal, invocation, tool context |
| CRUD, FetchXML/OData queries, entity/attribute/relationship/option-set schema | `add-dataverse-api` | `window.dataverseAPI` |
| Environment management, governance, licensing, analytics, or any Power Platform REST surface beyond Dataverse | `add-powerplatform-api` | `window.powerplatformAPI` + Entra app registration setup |
| Reading/writing local files, native save/select dialogs | `add-file-system-api` | `toolboxAPI.fileSystem` |
| Reacting to connection/settings/terminal/tool-lifecycle changes without polling | `add-events-api` | `toolboxAPI.events.on()` |
| Persisting user preferences across sessions | `add-settings-api` | `toolboxAPI.settings` |
| Reaching an external domain (CDN, external API, webfont) | `configure-csp` | `cspExceptions` in the manifest |
| A tool crashing silently, or needing consistent error/retry handling | `add-error-handling` | `try`/`catch`, logging, notifications, retry logic |
| Launching another installed tool, or being launched by one | `add-inter-tool-invocation` | `pptb.config.json` invocation contract, `launchTool()`/`getLaunchContext()`/`returnData()` |
| Exposing a tool to AI assistants via MCP, headless execution | `add-agent-integration` | `agents` object in `pptb.config.json`, `invokeHeadless()` |
| Checking a manifest before publishing | `validate-pptb-tool` | `pptb-validate` |
| Shipping a finished tool | `publish-pptb-tool` | npm publish + ToolBox registry submission |

If the compact table above doesn't disambiguate a request, see `references/skills-catalog.md` for each skill's full description and trigger phrases verbatim. If the request names a capability that isn't in either, don't guess — check `docs/pptb-tools/tool-development/api-reference/` for the underlying API surface before improvising.

## Typical build order

A new tool build usually starts with `create-pptb-tool`; an existing tool goes through `update-pptb-tool` first instead. From there it layers in whichever of `add-toolbox-api`, `add-dataverse-api`, `add-powerplatform-api`, `add-file-system-api`, `add-events-api`, and `add-settings-api` the tool's functionality actually requires. `configure-csp` runs whenever one of those integrations (or anything else) reaches an external domain. `add-error-handling` wraps the resulting API calls. `add-inter-tool-invocation` and `add-agent-integration` add cross-tool and AI-assistant behavior where the tool needs it. `validate-pptb-tool` and `publish-pptb-tool` close out the workflow before the tool reaches the registry.

Not every tool needs every skill — a simple utility tool might only need `create-pptb-tool`, one API skill, and `add-error-handling`.

## Related

- `toolbox-development` — the sibling entry point for contributors building the ToolBox host application itself, rather than a tool that runs inside it
- `docs/pptb-tools/tool-development/` — the architecture/workflow reference this skill is built on
