---
title: Overview
description: What tool development covers for the Power Platform Toolbox (PPTB) ecosystem.
source: https://docs.powerplatformtoolbox.com/tool-development
last_verified: 2026-07-22
---

# Overview

Power Platform ToolBox (PPTB) is a secure, extensible platform for creating custom tools as web applications. Tools run in sandboxed iframes with controlled API access rather than as arbitrary desktop code, so the host can broker access to Dataverse, Power Platform services, and local resources on the tool's behalf. This page is the starting point for anyone building a PPTB tool: it maps out the architecture, the development workflow, and where to go next.

**A PPTB tool is a web app (HTML/CSS/TypeScript) that declares itself through a package manifest and talks to the host exclusively through the ToolBox, Dataverse, and PowerPlatform APIs injected into its sandboxed iframe.**

## Architecture components

PPTB exposes three main API layers to a tool's webview:

- **ToolBox API** (`window.toolboxAPI`) — namespaced platform functionality: connection management, utilities (notifications, clipboard, theme, file operations), tool-specific settings storage, terminal creation and management, and platform event subscriptions.
- **Dataverse API** (`window.dataverseAPI`) — an HTTP client for CRUD operations, FetchXML queries, metadata operations, and action/function execution against Microsoft Dataverse.
- **PowerPlatform API** (`window.powerplatformAPI`) — direct, namespaced access to Power Platform service endpoints (environment management, governance, licensing, and more) beyond Dataverse.

See the [API Reference](/pptb-tools/tool-development/api-reference/) for the full surface of each.

## Development workflow

Building a tool follows this general path:

1. **Setup** — scaffold a new tool project using the Yeoman generator (`yo pptb`), installed globally or run via `npx`.
2. **Development** — implement the tool with HTML, CSS, and TypeScript. Install the `@pptb/types` npm package for TypeScript definitions covering the ToolBox, Dataverse, and PowerPlatform APIs.
3. **Manifest** — define `package.json` with the required PPTB-specific fields (name, icon path, contributors, configurations, and so on). See [Package Manifest](/pptb-tools/tool-development/package-manifest/).
4. **Testing** — enable the Debug Menu in ToolBox settings, then load your local, unpublished tool from the Debug section for testing against a real connection.
5. **Publishing** — build the project, finalize the package, publish it to npm, and submit it through the Tool Submission Form so it can be discovered inside ToolBox.

## Community resources

The PPTB team maintains a Discord server for discussing tool development, sharing ideas, and getting help from the community. Sample tools and reference documentation are available on the [sample-tools GitHub repository](https://github.com/PowerPlatformToolBox/sample-tools). If you're porting or adapting an existing XrmToolBox tool, the documentation asks that you respect the original tool authors when creating derivative works.

## Related links

- [Tool Development Guide (source)](https://docs.powerplatformtoolbox.com/tool-development)
- [Package Manifest](/pptb-tools/tool-development/package-manifest/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
