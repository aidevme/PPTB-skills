---
applyTo: "cspell.json"
---

# cspell.json maintenance instructions

Use `scripts/sync-cspell.ps1` to keep the `words` list in `cspell.json` in sync with the repository's Markdown content. Do not manually add words to `cspell.json` without first running the script.

## When to run

Run the script whenever:

- A CI spell-check job fails with `Unknown word` errors.
- New Markdown pages are added that introduce technical terms, proper names, or product identifiers not yet in `cspell.json`.
- You are unsure whether a word is already in the list.

## How to run

```powershell
# From the repository root — interactive, prompts for each unknown word
powershell -ExecutionPolicy Bypass -File scripts\sync-cspell.ps1

# Non-interactive — adds all unknown words automatically
powershell -ExecutionPolicy Bypass -File scripts\sync-cspell.ps1 -AutoAdd

# Scan one file or glob instead of every Markdown file
powershell -ExecutionPolicy Bypass -File scripts\sync-cspell.ps1 -MarkdownPath templates/workflows/codeql/README.md -AutoAdd
```

## What the script does

1. Runs cspell against every Markdown file, or the paths supplied through `-MarkdownPath`, and collects all `Unknown word` errors.
2. Skips words already present in `cspell.json`.
3. Prompts (or auto-adds with `-AutoAdd`) each new word.
4. Writes `cspell.json` back with the `words` array sorted alphabetically (case-insensitive).

## Rules for adding words

- Add proper names, acronyms, product names, and technical identifiers that are correct but unknown to cspell.
- Do not add misspellings — fix them in the source Markdown instead.
- Do not add common English words — if cspell flags a real word, verify the `"language"` field in `cspell.json` is set to `"en"`.
- Keep entries lowercase unless the word is a proper noun or acronym (e.g., `ADFS`, `aidevme`).
