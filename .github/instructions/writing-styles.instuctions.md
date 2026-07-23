---
applyTo: "docs/**/*.md"
---

# Writing style instructions

Follow [WRITING_STYLE.md](../../WRITING_STYLE.md) for the full guide with examples. Summary below.

## Page structure

Every page under `docs/<product-area>/` follows this order:

1. YAML frontmatter (`title`, `description`, `source`, `version`, `last_verified`)
1. Page title (H1) — matches frontmatter `title`
1. Intro paragraph — what the page covers and why it matters
1. "Key takeaway" callout or paragraph — the one thing to remember
1. Body sections (H2/H3)
1. Quick tips / suggested review checklist
1. Related links

Don't skip frontmatter, H1, or intro. Other sections are optional for stub pages.

## Frontmatter

```yaml
---
title: Page title
description: One-sentence summary of the page.
source: https://learn.microsoft.com/... # primary source, if any
version: x.y.z                          # product/platform version this applies to, if applicable
last_verified: YYYY-MM-DD               # date last checked against the source
---
```

Update `last_verified` whenever content is reconfirmed against its source, even without other changes.

## Content rules

- Address the reader as an architect/developer responsible for shipping a compliant solution, not a beginner.
- State the reader's responsibility clearly and bold the core takeaway.
- Use `##`/`###` for structure without skipping levels; prefer descriptive headings over generic ones.
- Use a bold-labeled blockquote for callouts (`> **Important:** ...`), not GitHub alert syntax. Reserve for responsibility statements and easy-to-miss caveats.
- Use tables for structured comparisons (standards conformance, configuration options); keep cells terse.
- End actionable sections with a `- [ ]` checklist of independently verifiable items.
- Link to primary sources rather than restating from memory; verify links resolve.
- Use relative paths for internal links, absolute URLs for external ones.
- End the page with `## Related links` listing cited sources plus the frontmatter `source`.
- Prefer restructuring/summarizing source material over copying it verbatim.

## Writing style

- Active voice, present tense.
- Direct, technical tone — no marketing language.
- Short, focused sentences — avoid stacking qualifiers into one clause.
- Be precise with standards terminology (e.g., WCAG 2.1 vs. 2.2, Section 508 vs. EN 301 549) — name the exact standard/version.
- Use "select" (not "click") and "field" (not "textbox"). Start configuration steps with an action verb (Select, Enter, Navigate, Configure) and bold the exact UI text.
