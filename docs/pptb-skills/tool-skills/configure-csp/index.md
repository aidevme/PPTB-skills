---
title: configure-csp
description: Adds and scopes cspExceptions entries in the manifest for external domains a tool needs to reach.
last_verified: 2026-07-22
---

# configure-csp

This skill automates declaring Content Security Policy exceptions in a PPTB tool's `package.json` — the narrowly-scoped permissions a tool requests when it needs to reach a CDN, an external API, a webfont, or embed external content beyond the host's strict default policy. A developer reaches for it whenever a tool hits a CSP violation in the console, or before adding a new external dependency that the default policy would block.

**Every exception this skill adds must use the most specific `domain` possible, carry an `exceptionReason` written for the end user, and be marked `optional: true` when the tool's core functionality doesn't strictly require it — the host only relaxes the default policy after the user explicitly consents to what the dialog shows.**

## When to use it

- "My tool is getting CSP violation errors in the console"
- "Add a CSP exception so I can call this external API"
- "I need to load a CDN library / webfont / external stylesheet"
- "Allow this tool to embed content from this domain in an iframe"
- "Let users click mailto links in my tool"
- Before submitting a tool to the registry, to confirm `cspExceptions` are minimal and justified

## Inputs

- Which directive is needed: `connect-src`, `script-src`, `style-src`, `img-src`, `font-src`, `frame-src`, `media-src`, or `mailto`
- The specific external domain(s) the tool needs to reach
- Why the tool needs each domain (used to write `exceptionReason`)
- Whether the exception is essential to core functionality or merely enhances it (determines `optional`)
- Whether a bundling, backend-proxy, or built-in Dataverse API alternative was already considered

## What it does

1. Adds a `cspExceptions` object to `package.json` (if not already present) with an array under the relevant directive(s): `connect-src`, `script-src`, `style-src`, `img-src`, `font-src`, `frame-src`, `media-src`, `mailto`.
2. For each domain, adds an entry object with `domain` (required), `exceptionReason` (markdown, written for the end user, shown in the consent dialog), and `optional: true` when the feature is non-essential — defaulting `optional` to `false`/omitted otherwise.
3. Prefers the most specific domain pattern available (e.g. `https://cdn.example.com` over `https://*.example.com`), and refuses to generate a bare `https:` scheme or an unscoped `*`.
4. Before adding an exception, checks for and surfaces alternatives: bundling the library instead of loading it from a CDN, proxying API calls through a secure backend, or using PPTB's built-in `dataverseAPI` instead of calling Dataverse endpoints directly.
5. Reminds the developer to reload the tool after editing `cspExceptions` so the consent dialog reflects the change.
6. Keeps the `cspExceptions` block in `package.json` in sync with what will be submitted in the registry entry at publish time.

## Example

Before: a tool with no `cspExceptions` that needs to call Power BI's embed API and load Mermaid from a CDN.

After (`package.json`):

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
  }
}
```

## Checklist it enforces

- [ ] Every requested exception uses the most specific domain possible — no bare `*` or unscoped `https:`.
- [ ] Every entry has an `exceptionReason` written for the end user, using markdown where helpful.
- [ ] Non-essential exceptions are marked `optional: true`.
- [ ] Alternatives (bundling, backend proxy, built-in Dataverse API) were considered before requesting an exception.
- [ ] The tool is reloaded after editing `cspExceptions` to confirm the consent dialog reflects the change.
- [ ] `cspExceptions` in `package.json` matches what's submitted in the registry entry.

## Related

- [CSP Configuration](/pptb-tools/tool-development/csp-configuration/) — the CSP model and directive reference this skill is built on
- Related skills: `../create-pptb-tool/`, `../validate-pptb-tool/`
