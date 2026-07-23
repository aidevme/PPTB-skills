---
applyTo: ".github/CODEOWNERS"
---

# CODEOWNERS maintenance instructions

Use `scripts/sync-code-owners.ps1` to keep the auto-generated `docs/` section of `.github/CODEOWNERS` in sync with the actual contents of the `docs/` folder. Do not manually add, remove, or reorder lines between the `# BEGIN AUTO-GENERATED: docs` / `# END AUTO-GENERATED: docs` markers.

## When to run

Run the script whenever:

- A file or folder is added to, removed from, or renamed under `docs/`.
- A CI check reports that the `docs/` section of `CODEOWNERS` is out of date.
- You are unsure whether `CODEOWNERS` still reflects the current `docs/` structure.

## How to run

```powershell
# From the repository root — updates CODEOWNERS in place
powershell -ExecutionPolicy Bypass -File scripts\sync-code-owners.ps1

# CI / pre-commit check — exits 1 without writing if CODEOWNERS is stale
powershell -ExecutionPolicy Bypass -File scripts\sync-code-owners.ps1 -Check

# Preview the exact lines that would change, without writing
powershell -ExecutionPolicy Bypass -File scripts\sync-code-owners.ps1 -WhatIf

# Assign a different owner to every generated docs/ entry
powershell -ExecutionPolicy Bypass -File scripts\sync-code-owners.ps1 -Owner '@aidevme/docs-team'
```

## What the script does

1. Runs `git ls-files -- docs` to list every git-tracked file under `docs/` (gitignored build output such as `docs/.vitepress/dist` and `docs/.vitepress/cache` is skipped automatically).
2. Generates one CODEOWNERS pattern per Markdown file directly in `docs/` (e.g., `docs/index.md`) and one `<dir>/**` pattern per `docs/` subdirectory, at any depth, that directly contains a tracked file (e.g., `docs/references/mcps/**`).
3. Replaces the content between the `# BEGIN AUTO-GENERATED: docs` / `# END AUTO-GENERATED: docs` markers with the generated, alphabetically sorted patterns, each assigned to `-Owner` (default `@aidevme`).
4. Leaves every other section of `CODEOWNERS` untouched.

## Rules for editing CODEOWNERS

- Edit non-docs sections (repository governance, CI/CD and repo tooling, the default `*` owner) by hand as normal.
- Never hand-edit a line between the `# BEGIN AUTO-GENERATED: docs` and `# END AUTO-GENERATED: docs` markers — the next script run overwrites it.
- If the markers are missing or damaged, restore them around the `# Documentation` section before rerunning the script; it refuses to run without them.
- To change who owns `docs/`, rerun the script with `-Owner`, or edit `$Owner`'s default in `scripts/sync-code-owners.ps1` — don't retype owners into the generated lines.
