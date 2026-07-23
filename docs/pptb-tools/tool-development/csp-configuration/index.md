---
title: CSP Configuration
description: How a PPTB tool declares Content Security Policy exceptions for external resources, and how consent is enforced.
source: https://docs.powerplatformtoolbox.com/tool-development/csp-configuration
last_verified: 2026-07-22
---

# CSP Configuration

Power Platform ToolBox enforces a strict default Content Security Policy (CSP) for every tool, and lets a tool request specific, narrowly-scoped exceptions when it genuinely needs to reach external resources — a CDN library, an external API, a webfont. This page covers what CSP is in this context, how to declare exceptions in your tool's manifest, and how the consent flow works for users.

**Request only the exact domains your tool needs, explain each exception with `exceptionReason`, and mark anything non-essential as `optional: true` — the host will only relax the default policy after the user explicitly consents.**

## What is CSP?

Content Security Policy is a security standard that prevents cross-site scripting (XSS) and code-injection attacks by controlling which resources a web page is allowed to load. PPTB's default strict CSP restricts:

- Scripts and styles to tool-internal sources only.
- Network requests to the tool itself.
- External fonts and resources.

Images may load from the tool, `data:` URIs, or HTTPS sources.

## Why per-tool CSP?

Some tools legitimately need more: calls to an external API, a visualization library loaded from a CDN, an external stylesheet or font, or embedded external content. Rather than weakening CSP globally for every tool, each tool requests only the exceptions it needs, and the user grants (or denies) them explicitly.

## How it works

### For users

1. On first launch, a tool requiring CSP exceptions shows a consent dialog.
2. The dialog lists exactly which external resources the tool needs and why.
3. The user can accept or decline.
4. Accepted consent is stored, so the user isn't prompted repeatedly.
5. Exceptions apply only where consent was granted.
6. Consent can be revoked at any time via the IPC API.

### For developers

Declare CSP exceptions in your tool's `package.json` manifest under `cspExceptions`:

```json
{
  "name": "@power-maverick/dataverse-erd-generator",
  "displayName": "Dataverse ERD Generator",
  "version": "1.0.0",
  "description": "Generate Entity Relationship Diagrams from Dataverse",
  "author": "Power Maverick",
  "icon": "icons/test.svg",
  "features": {
    "minAPI": "1.2.0"
  },
  "cspExceptions": {
    "connect-src": [
      {
        "domain": "https://*.dynamics.com",
        "exceptionReason": "Required to **fetch** metadata and records from Dataverse."
      },
      {
        "domain": "https://*.crm*.dynamics.com",
        "exceptionReason": "Required to connect to region-specific Dataverse environments."
      }
    ],
    "script-src": [
      {
        "domain": "https://cdn.jsdelivr.net",
        "exceptionReason": "Loads the Mermaid diagram library used to render ERDs."
      }
    ],
    "style-src": [
      {
        "domain": "https://cdn.jsdelivr.net",
        "exceptionReason": "Loads Mermaid's bundled stylesheet.",
        "optional": true
      }
    ],
    "img-src": [
      {
        "domain": "https://example.com/images",
        "exceptionReason": "Displays entity icons in the diagram."
      }
    ],
    "mailto": [
      {
        "domain": "mailto:url",
        "exceptionReason": "Allows users to click email links in the tool."
      }
    ]
  }
}
```

Reload the tool after adding CSP exceptions to trigger the consent dialog again.

## Implementation details

The CSP enforcement flow:

1. Tool CSP exceptions are read from `package.json` during installation.
2. When the tool launches, the system checks for declared CSP exceptions.
3. If exceptions exist, the system checks whether the user has already granted consent.
4. If not granted, a consent dialog is shown.
5. When the tool's HTML is served, `WebviewProtocolManager` checks the consent status.
6. Exceptions apply only with granted consent.
7. Without consent, the tool receives the default restrictive CSP.

## Supported CSP directives

PPTB supports the following directives. Each accepts an array of entries — either a plain string domain, or an object with these properties:

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `domain` | string | Yes | The origin/domain to allow |
| `exceptionReason` | string | No | Markdown description of why the exception is needed; shown in the consent dialog |
| `optional` | boolean | No | When `true`, the core tool works without this exception; it only enables additional features. Defaults to `false` |

### `connect-src`

Controls which URLs the tool can reach via XHR, fetch, WebSocket, etc.

```json
[
  {
    "domain": "https://*.dynamics.com",
    "exceptionReason": "Fetches metadata and records from Dataverse."
  }
]
```

### `script-src`

Controls which sources can load JavaScript.

```json
[
  {
    "domain": "https://cdn.jsdelivr.net",
    "exceptionReason": "Loads the Mermaid diagram library."
  }
]
```

### `style-src`

Controls which sources can load CSS.

```json
[
  {
    "domain": "https://fonts.googleapis.com",
    "exceptionReason": "Provides the UI font family.",
    "optional": true
  }
]
```

### `img-src`

Controls which sources can load images.

```json
[
  {
    "domain": "https://example.com/images",
    "exceptionReason": "Displays entity icons in the diagram."
  }
]
```

### `font-src`

Controls which sources can load fonts.

```json
[
  {
    "domain": "https://fonts.gstatic.com",
    "exceptionReason": "Serves the UI font files.",
    "optional": true
  }
]
```

### `frame-src`

Controls which sources can be embedded in frames.

```json
[
  {
    "domain": "https://trusted-domain.com",
    "exceptionReason": "Embeds the interactive report viewer."
  }
]
```

### `media-src`

Controls which sources can load video/audio.

```json
[
  {
    "domain": "https://media-cdn.com",
    "exceptionReason": "Streams tutorial videos within the tool.",
    "optional": true
  }
]
```

### `mailto`

Controls whether `mailto:` links are allowed.

```json
[
  {
    "domain": "mailto:url",
    "exceptionReason": "Allows users to click email links in the tool."
  }
]
```

## Default CSP policy

Every tool starts with this default policy, and tool-specified exceptions are **added** to it, not used to replace it:

```text
default-src 'self';
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline';
img-src 'self' data: https:;
font-src 'self' data:;
connect-src 'self';
```

## Best practices

### Request only what you need

Only request exceptions your tool actually uses. Users trust tools that request minimal permissions.

**Bad:**

```json
{
  "cspExceptions": {
    "connect-src": ["*"],
    "script-src": ["*"]
  }
}
```

**Good:**

```json
{
  "cspExceptions": {
    "connect-src": [
      {
        "domain": "https://api.powerbi.com",
        "exceptionReason": "Embeds Power BI reports."
      },
      {
        "domain": "https://*.dynamics.com",
        "exceptionReason": "Fetches Dataverse metadata."
      }
    ],
    "script-src": [
      {
        "domain": "https://cdn.jsdelivr.net/npm/mermaid@9",
        "exceptionReason": "Loads the Mermaid diagram library."
      }
    ]
  }
}
```

### Use specific domains

Prefer the most specific domain pattern you can. Prefer `https://cdn.example.com` over `https://*.example.com`, and avoid a bare `https:` scheme, which allows any HTTPS site.

### Document your requirements

Use `exceptionReason` on every entry — it supports markdown and is shown directly in the consent dialog, so write it for the end user, not just for yourself. Mark anything the tool doesn't strictly need as `optional: true`:

```json
"cspExceptions": {
  "style-src": [
    {
      "domain": "https://fonts.googleapis.com",
      "exceptionReason": "Loads the preferred UI font. The tool works with the system font if this is declined.",
      "optional": true
    }
  ]
}
```

### Consider alternatives

Before requesting an exception, ask:

- Can you bundle the library instead of loading it from a CDN?
- Can you proxy API calls through a secure backend?
- Can you use PPTB's built-in Dataverse API instead of calling Dataverse directly?

## Revoking consent

> **Note:** Full UI for consent management is planned for a future release; today this is a manual/developer-console workaround.

Users can revoke CSP consent for a tool:

1. Go to Settings.
2. Navigate to Security / CSP Permissions (future feature).
3. Find the tool and select **Revoke Consent**.
4. The consent dialog reappears the next time the tool launches.

Alternatively, consent is stored in the user settings file and can be edited manually.

## Registry configuration

Include `cspExceptions` in your registry entry when publishing to the PPTB registry:

```json
{
  "id": "dataverse-erd-generator",
  "name": "Dataverse ERD Generator",
  "version": "1.0.0",
  "author": "Power Maverick",
  "downloadUrl": "...",
  "cspExceptions": {
    "connect-src": [
      {
        "domain": "https://*.dynamics.com",
        "exceptionReason": "Fetches metadata and records from Dataverse."
      }
    ],
    "script-src": [
      {
        "domain": "https://cdn.jsdelivr.net",
        "exceptionReason": "Loads the Mermaid diagram library."
      }
    ]
  }
}
```

Local tools can declare CSP exceptions in `package.json` too — the same consent flow applies to locally-loaded development tools.

## Troubleshooting

### Tool shows CSP violation errors in the browser console

1. Check whether CSP consent has been granted for the tool.
2. Verify the tool's exceptions actually include the blocked resource.
3. Contact the tool developer if the exceptions look incorrect.

### Consent dialog doesn't appear

1. Check the browser console for JavaScript errors.
2. Clear the tool from open tabs and try again.
3. Check whether consent was already granted in settings.

### Can't find how to revoke consent

1. Use the developer console: `window.toolboxAPI.revokeCspConsent('tool-id')`.
2. Manually edit the settings file in the app's user data directory.
3. A full consent-management UI is planned for a future release.

## Complete example

```json
{
  "name": "@your-org/your-tool",
  "displayName": "My Awesome Tool",
  "version": "1.0.0",
  "description": "A tool that does amazing things with Dataverse",
  "author": "Your Name",
  "main": "dist/index.html",
  "icon": "icons/test.svg",
  "features": {
    "minAPI": "1.2.0"
  },
  "cspExceptions": {
    "connect-src": [
      {
        "domain": "https://*.dynamics.com",
        "exceptionReason": "Required to **fetch metadata and records** from Dataverse."
      },
      {
        "domain": "https://*.crm*.dynamics.com",
        "exceptionReason": "Required to connect to region-specific Dataverse environments."
      }
    ],
    "script-src": [
      {
        "domain": "https://cdn.jsdelivr.net/npm/mermaid@10",
        "exceptionReason": "Loads the **Mermaid** library used to render entity relationship diagrams."
      }
    ],
    "style-src": [
      {
        "domain": "https://cdn.jsdelivr.net/npm/mermaid@10",
        "exceptionReason": "Loads Mermaid's bundled stylesheet for diagram rendering.",
        "optional": true
      }
    ]
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/your-org/your-tool"
  },
  "license": "MIT"
}
```

## Future enhancements

Planned improvements include a settings UI for managing consent, temporary/one-time consent, a detailed audit log of when a tool uses its permissions, pre-approved CSP templates for common scenarios, and differentiated warning levels for low- vs. high-risk permissions.

## Checklist

- [ ] Every requested exception uses the most specific domain possible — no bare `*` or unscoped `https:`.
- [ ] Every entry has an `exceptionReason` written for the end user, using markdown where helpful.
- [ ] Non-essential exceptions are marked `optional: true`.
- [ ] Alternatives (bundling, backend proxy, built-in Dataverse API) were considered before requesting an exception.
- [ ] The tool was reloaded after editing `cspExceptions` to confirm the consent dialog reflects the change.
- [ ] `cspExceptions` in `package.json` matches what's submitted in the registry entry.

## Related links

- [CSP Configuration (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/csp-configuration)
- [MDN: Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)
- [OWASP: Content Security Policy Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Content_Security_Policy_Cheat_Sheet.html)
- [Tool Development](/pptb-tools/tool-development/)
- [Publishing Tools](/pptb-tools/tool-development/publishing-tools/)
