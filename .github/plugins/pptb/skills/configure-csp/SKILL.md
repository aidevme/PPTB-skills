---
name: configure-csp
description: Adds and scopes `cspExceptions` entries in a PPTB tool's `package.json` manifest for external domains the tool needs to reach — CDN scripts, external APIs, webfonts, embedded frames. Use when asked to "add a CSP exception", "let my tool call this external API", "load this library from a CDN", "my tool shows a CSP violation in the console", or "configure Content Security Policy" for a tool.
---

# Configure CSP

Power Platform ToolBox enforces a strict default Content Security Policy for every tool, and only relaxes it where a tool explicitly declares — and the user explicitly consents to — a narrowly-scoped exception. This skill adds `cspExceptions` entries to a tool's manifest for the external domains it genuinely needs, and keeps each one minimal and explained.

**Request only the exact domains the tool needs, give every entry an `exceptionReason` written for the end user, and mark anything non-essential as `optional: true` — the host only relaxes the default policy after the user explicitly consents, and over-broad requests (`"*"`, a bare `https:` scheme) erode that trust.**

## Step 1: Confirm an exception is actually needed

Before adding anything, check whether the external reach can be avoided instead:

- Can the library be bundled into the tool's own build instead of loaded from a CDN?
- Can the call be proxied through a secure backend the tool already controls?
- Can `dataverseAPI`/`powerplatformAPI` cover this instead of the tool reaching Dataverse/Power Platform directly?

Only proceed to declaring a `cspExceptions` entry once none of these alternatives fit.

## Step 2: Pick the right directive

Every tool starts from this default policy, and declared exceptions are **added** to it, not used to replace it:

```text
default-src 'self';
script-src 'self' 'unsafe-inline';
style-src 'self' 'unsafe-inline';
img-src 'self' data: https:;
font-src 'self' data:;
connect-src 'self';
```

| Directive | Controls | Typical use |
| --- | --- | --- |
| `connect-src` | `fetch`/`XHR`/`WebSocket` targets | Calling an external REST API |
| `script-src` | Sources allowed to serve JavaScript | Loading a library from a CDN |
| `style-src` | Sources allowed to serve CSS | An external stylesheet or CDN-hosted CSS |
| `img-src` | Sources allowed to serve images | Images hosted outside the tool |
| `font-src` | Sources allowed to serve fonts | Webfonts (e.g. Google Fonts) |
| `frame-src` | Sources allowed to be embedded in `<iframe>`s | Embedding an external report/viewer |
| `media-src` | Sources allowed to serve audio/video | Streaming external media |
| `mailto` | Whether `mailto:` links are allowed | `mailto:` links in the tool's UI |

## Step 3: Add the exception to `package.json`

Each directive takes an array of entries — a plain domain string, or (preferred) an object with `domain`, `exceptionReason`, and `optional`:

```json
{
  "cspExceptions": {
    "connect-src": [
      {
        "domain": "https://*.dynamics.com",
        "exceptionReason": "Required to **fetch** metadata and records from Dataverse."
      }
    ],
    "script-src": [
      {
        "domain": "https://cdn.jsdelivr.net/npm/mermaid@10",
        "exceptionReason": "Loads the **Mermaid** library used to render diagrams."
      }
    ],
    "style-src": [
      {
        "domain": "https://fonts.googleapis.com",
        "exceptionReason": "Loads the preferred UI font. The tool works with the system font if this is declined.",
        "optional": true
      }
    ]
  }
}
```

Always write `exceptionReason` for the end user, not just for a future developer — it's rendered as markdown directly in the consent dialog the user sees before granting the exception. Mark anything the tool doesn't strictly need to function as `optional: true`; the core tool must keep working when an optional exception is declined.

## Step 4: Use the most specific domain possible

Prefer `https://cdn.example.com` over `https://*.example.com`, and never use a bare `*` or an unscoped `https:` — both grant access far beyond what the tool actually needs and will be flagged during registry review:

```json
// Bad
{ "cspExceptions": { "connect-src": ["*"], "script-src": ["*"] } }

// Good
{
  "cspExceptions": {
    "connect-src": [{ "domain": "https://api.powerbi.com", "exceptionReason": "Embeds Power BI reports." }]
  }
}
```

## Step 5: Reload and verify consent

After editing `cspExceptions`, reload the tool to trigger the consent dialog again — a change won't take effect until the user re-consents. Confirm the dialog lists exactly the domains just added, with the `exceptionReason` text rendering correctly.

If the tool still shows CSP violations in the browser console after this:

1. Confirm consent was actually granted (not just requested).
2. Verify the declared exception's directive and domain actually match the blocked resource — a `connect-src` exception won't cover a blocked `script-src` load, for example.
3. Recheck the domain pattern is specific enough to match the exact origin being loaded.

## Step 6: Carry `cspExceptions` through to the registry entry

When publishing (see `publish-pptb-tool`), the registry submission's `cspExceptions` must match what's declared in `package.json` — keep the two in sync rather than letting them drift.

## Checklist

- [ ] Every requested exception uses the most specific domain possible — no bare `*` or unscoped `https:`.
- [ ] Every entry has an `exceptionReason` written for the end user, using markdown where helpful.
- [ ] Non-essential exceptions are marked `optional: true`.
- [ ] Alternatives (bundling, backend proxy, built-in Dataverse API) were considered before requesting an exception.
- [ ] The tool was reloaded after editing `cspExceptions` to confirm the consent dialog reflects the change.
- [ ] `cspExceptions` in `package.json` matches what's submitted in the registry entry.

## Next steps

- `add-toolbox-api` / `add-dataverse-api` / `add-powerplatform-api` — check whether a built-in API can replace a direct external call before reaching for a CSP exception
- `validate-pptb-tool` — `pptb-validate` checks `cspExceptions` shape as part of the manifest
- `publish-pptb-tool` — keep the registry submission's CSP declaration in sync with `package.json`
