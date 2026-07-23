---
title: Package Manifest
description: The manifest file that declares a PPTB tool's identity, capabilities, and requirements.
source: https://docs.powerplatformtoolbox.com/tool-development/manifest
last_verified: 2026-07-22
---

# Package Manifest

Every PPTB tool ships a `package.json` file at the root of its distribution. This file describes your tool to the ToolBox host and to the npm registry: what it's called, how to load it, what capabilities it needs, and which external origins it's allowed to talk to. Getting the manifest right is a prerequisite for your tool loading correctly and for passing registry submission review.

**The manifest follows the standard npm `package.json` format plus PPTB-specific fields — `name`, `version`, `displayName`, `description`, `main`, `icon`, `license`, `contributors`, and `configurations` are all required, and the host will refuse to load a tool that's missing them.**

> **Note:** `iconURL` under `configurations` is no longer supported. Use the top-level `icon` field instead, with an SVG path relative to your `dist` root.

## Required fields

| Field | Type | Description | Sample |
| ------- | ------ | ------------- | -------- |
| `name` | `string` | Scoped npm package name — lowercase, no spaces | `"@myorg/my-tool"` |
| `version` | `string` | SemVer-compatible version | `"1.0.0"` |
| `displayName` | `string` | Human-readable name shown in the ToolBox UI | `"My Awesome Tool"` |
| `description` | `string` | Short description of what the tool does | `"Manage Dataverse solutions"` |
| `main` | `string` | Entry-point file relative to the `dist` root | `"index.html"` |
| `icon` | `string` | Path to SVG icon relative to the `dist` root. Use `fill="currentColor"` to support light/dark themes | `"icons/tool.svg"` |
| `license` | `string` | An approved open-source license identifier | `"MIT"` |
| `contributors` | `array` | One or more objects, each with at least a `name` and optional `url` | see below |
| `configurations` | `object` | PPTB-specific links and metadata | see below |

Allowed license identifiers: `MIT`, `Apache-2.0`, `BSD-2-Clause`, `BSD-3-Clause`, `GPL-2.0`, `GPL-3.0`, `LGPL-3.0`, `ISC`, `AGPL-3.0-only`.

```json
"contributors": [
  { "name": "Jane Dev", "url": "https://janedev.com" },
  { "name": "John Doe" }
]
```

## Configurations object

Nested inside the top-level `configurations` key:

| Field | Required | Type | Description | Sample |
| ------- | ---------- | ------ | ------------- | -------- |
| `repository` | Yes | `string` | URL of the tool's source repository — shown in the ToolBox help menu | `"https://github.com/myorg/my-tool"` |
| `website` | No | `string` | Tool website or documentation URL | `"https://docs.myorg.com/my-tool"` |
| `readmeUrl` | No | `string` | Raw `githubusercontent.com` URL for the README — used to display docs inside ToolBox | `"https://raw.githubusercontent.com/myorg/my-tool/main/README.md"` |

## Optional fields

| Field | Type | Description | Sample |
| ------- | ------ | ------------- | -------- |
| `homepage` | `string` | Public homepage URL | `"https://myorg.com"` |
| `repository` | `object` | Standard npm repository object | `{ "type": "git", "url": "https://github.com/…" }` |
| `cspExceptions` | `object` | Additional Content Security Policy origins your tool connects to | see below |
| `features` | `object` | Declare special ToolBox capabilities required by your tool | see below |

## Features object

Declare ToolBox-specific capabilities your tool needs. Omit this section entirely if neither field applies.

| Field | Type | Values | Description | Sample |
| ------ | ------ | ------ | ------ | ------ |
| `multiConnection` | `string` | `"optional"` or `"required"` | Whether the tool supports or requires a second Dataverse connection | `"optional"` |
| `minAPI` | `string` | SemVer | Minimum ToolBox API version the tool requires | `"1.2.0"` |

```json
"features": {
  "multiConnection": "optional",
  "minAPI": "1.2.0"
}
```

### Setting `minAPI`

When a user installs or opens your tool, ToolBox checks `minAPI` against the currently installed ToolBox version. If the installed version is older than the minimum required, ToolBox alerts the user and recommends upgrading before they can use the tool.

Set `minAPI` when:

- Your tool calls an API or uses a feature introduced in a specific ToolBox release (for example, `multiConnection` requires **1.2.0** or later).
- You want to prevent runtime errors caused by a user running an older, incompatible version of ToolBox.

Each function documented in the [API Reference](/pptb-tools/tool-development/api-reference/) includes a **Requires vX.Y.Z** badge showing the minimum ToolBox version it needs, where applicable. Set `minAPI` to the highest such version across all the functions your tool depends on. You only need to set this field if your tool relies on features that weren't available in the very first public release; if your tool only uses core APIs available from the start, omit it. Setting `minAPI` higher than necessary blocks users on older, otherwise-compatible ToolBox versions — always use the lowest version that covers everything you actually need.

## CSP exceptions object

Declare additional external origins that your tool's iframe is permitted to connect to. Omit this section entirely if your tool only communicates with Dataverse endpoints. All fields are optional.

Each directive accepts an array of entries. An entry can be a plain string (just the domain) or an object:

| Field | Type | Required | Description | Sample |
| ------- | ------ | ---------- | ------------- | -------- |
| `domain` | `string` | Yes | The origin/domain to allow | `"api.example.com"` |
| `exceptionReason` | `string` | No | Markdown description explaining why this exception is needed. Shown to users in the consent dialog | `"Used to **read** configuration details."` |
| `optional` | `boolean` | No | When `true`, the exception is optional — the core tool works without it, but granting it enables additional functionality. Defaults to `false` | `true` |

Supported CSP directives:

| Directive | Description | Sample domain |
| ----------- | ------------- | ---------------- |
| `connect-src` | Fetch, XHR, WebSocket, and EventSource origins | `"api.example.com"` |
| `script-src` | Additional origins allowed to serve scripts | `"cdn.example.com"` |
| `style-src` | Additional origins allowed to serve stylesheets | `"fonts.googleapis.com"` |
| `img-src` | Additional origins allowed to serve images | `"img.example.com"` |
| `font-src` | Additional origins allowed to serve fonts | `"fonts.gstatic.com"` |
| `frame-src` | Origins allowed to be embedded in iframes | `"embed.example.com"` |
| `media-src` | Origins allowed to serve audio/video media | `"media.example.com"` |

```json
"cspExceptions": {
  "connect-src": [
    {
      "domain": "api.example.com",
      "exceptionReason": "Used to **fetch** live data for the dashboard."
    }
  ],
  "script-src": [
    {
      "domain": "cdn.example.com",
      "exceptionReason": "Loads the charting library used to render reports."
    }
  ],
  "style-src": [
    {
      "domain": "fonts.googleapis.com",
      "exceptionReason": "Provides the UI font family.",
      "optional": true
    }
  ],
  "img-src": ["img.example.com"],
  "font-src": ["fonts.gstatic.com"],
  "frame-src": ["embed.example.com"],
  "media-src": ["media.example.com"]
}
```

> **Important:** Only add origins you genuinely need. Unnecessary CSP exceptions are flagged during registry submission review.

## Full example

```json
{
  "name": "@myorg/my-awesome-tool",
  "version": "1.0.0",
  "displayName": "My Awesome Tool",
  "description": "Manage Dataverse solutions across environments with ease.",
  "main": "index.html",
  "icon": "icons/tool.svg",
  "license": "MIT",
  "contributors": [
    { "name": "Jane Dev", "url": "https://janedev.com" },
    { "name": "John Doe" }
  ],
  "configurations": {
    "repository": "https://github.com/myorg/my-awesome-tool",
    "website": "https://docs.myorg.com/my-awesome-tool",
    "readmeUrl": "https://raw.githubusercontent.com/myorg/my-awesome-tool/main/README.md"
  },
  "features": {
    "multiConnection": "optional",
    "minAPI": "1.2.0"
  },
  "cspExceptions": {
    "connect-src": [
      {
        "domain": "api.example.com",
        "exceptionReason": "Used to **fetch** live configuration data for the dashboard."
      }
    ],
    "img-src": [
      {
        "domain": "img.example.com",
        "exceptionReason": "Loads thumbnails for the media browser.",
        "optional": true
      }
    ]
  },
  "keywords": ["dataverse", "power-platform", "solutions"],
  "homepage": "https://docs.myorg.com/my-awesome-tool",
  "repository": {
    "type": "git",
    "url": "https://github.com/myorg/my-awesome-tool.git"
  },
  "bugs": {
    "url": "https://github.com/myorg/my-awesome-tool/issues"
  },
  "dependencies": {},
  "devDependencies": {
    "@pptb/types": "^1.0.0",
    "typescript": "^5.0.0",
    "vite": "^5.0.0"
  },
  "scripts": {
    "build": "vite build",
    "dev": "vite"
  }
}
```

## Checklist

- [ ] `name`, `version`, `displayName`, `description`, `main`, `icon`, `license`, `contributors`, and `configurations` are all present.
- [ ] `license` uses one of the approved identifiers.
- [ ] Each entry in `contributors` has at least a `name`.
- [ ] `configurations.repository` points to a real, reachable source repository.
- [ ] `icon` is an SVG path relative to `dist`, with `fill="currentColor"` so it adapts to light/dark themes.
- [ ] `features.minAPI` (if set) matches the highest **Requires vX.Y.Z** badge among the APIs your tool actually calls.
- [ ] `cspExceptions` lists only origins the tool genuinely needs, each with a clear `exceptionReason`.

## Related links

- [Package Manifest (source)](https://docs.powerplatformtoolbox.com/tool-development/manifest)
- [Overview](/pptb-tools/tool-development/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
