---
title: API Reference
description: The full set of APIs a PPTB tool can call into.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference
last_verified: 2026-07-22
---

# API Reference

This page indexes the complete set of APIs available to a tool running inside Power Platform ToolBox. Use it as a map: each API below covers a distinct capability, and the detailed reference for each lives on its own page.

**Everything a tool can do — talk to the host shell, read/write Dataverse, call Power Platform service endpoints, persist settings, touch the file system, or react to platform events — goes through one of these documented APIs; there is no undocumented back channel into the host.**

## API categories

- **[ToolBox API](/pptb-tools/tool-development/toolbox-api/)** — platform features including connections, utilities, and terminal management.
- **[Dataverse API](/pptb-tools/tool-development/dataverse-api/)** — complete HTTP client for interacting with Microsoft Dataverse.
- **[PowerPlatform API](/pptb-tools/tool-development/powerplatform-api/)** — direct access to Power Platform service endpoints and management operations.
- **[Events API](/pptb-tools/tool-development/events-api/)** — subscribe to platform events like connection changes and settings updates.
- **[Settings API](/pptb-tools/tool-development/settings-api/)** — persistent storage for tool-specific preferences and configuration.
- **File System API** — secure file operations for reading, writing, and managing files.
- **Error Handling** — best practices for handling errors gracefully.

For complete TypeScript definitions covering all of the above, install the `@pptb/types` package:

```bash
npm install --save-dev @pptb/types
```

## Getting started path

For developers new to PPTB, the documentation recommends this sequence:

1. **Quickstart Guide** — get up and running quickly.
2. **[ToolBox API](/pptb-tools/tool-development/toolbox-api/)** — learn about platform features.
3. **[PowerPlatform API](/pptb-tools/tool-development/powerplatform-api/)** — call Power Platform service endpoints.
4. **[Dataverse API](/pptb-tools/tool-development/dataverse-api/)** — start interacting with Dataverse.
5. **Error Handling** — implement robust error handling.

## Related links

- [API Reference (source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference)
- [Overview](/pptb-tools/tool-development/)
- [ToolBox API](/pptb-tools/tool-development/toolbox-api/)
- [Dataverse API](/pptb-tools/tool-development/dataverse-api/)
- [PowerPlatform API](/pptb-tools/tool-development/powerplatform-api/)
- [Events API](/pptb-tools/tool-development/events-api/)
- [Settings API](/pptb-tools/tool-development/settings-api/)
