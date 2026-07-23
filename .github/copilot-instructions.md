# Copilot instructions

## Commands

- Install the locked Node dependencies with `npm ci`.
- Start the VitePress development server with `npm run docs:dev`.
- Build the documentation site with `npm run docs:build`.
- Preview a completed build with `npm run docs:preview`.
- Lint all Markdown with `npm run lint:md`.
- Lint one Markdown file with `npx markdownlint-cli2 path\to\file.md`.
- There is currently no automated test command or test suite. Do not infer one from the installed Playwright dependency.

Prefer the npm scripts over `scripts/validate-markdown.ps1`. The PowerShell script assumes `markdownlint-cli2` and `cspell` are available as global commands, while only markdownlint is installed by this package.

## Architecture

This repository is a reusable, documentation-first GitHub repository template:

- `docs/` is the VitePress content root. Markdown files become site routes.
- `docs/.vitepress/config.mts` owns site-wide metadata, navigation, social links, and footer configuration.
- `docs/index.md` is the VitePress home page and uses VitePress `layout: home`, `hero`, and `features` frontmatter rather than the standard content-page template.
- `WRITING_STYLE.md` is the source of truth for documentation structure and editorial rules. `.github/instructions/writing-styles.instuctions.md` applies its condensed rules to `docs/**/*.md`.
- Root `assets/` contains images used by repository-level Markdown such as `README.md` and `WRITING_STYLE.md`.
- GitHub issue forms and scoped Copilot instructions live under `.github/`.
- `templates/workflows/codeql/` contains inactive single-language CodeQL workflows that users copy into generated repositories.

Treat `docs/.vitepress/cache/` and `docs/.vitepress/dist/` as generated output. Never edit or commit them; change the Markdown source or VitePress config instead.

## Documentation conventions

- Product-area pages under `docs/<product-area>/` require YAML frontmatter with `title`, `description`, `source`, `version`, and `last_verified`, followed by an H1 matching `title` and a short introduction. Update `last_verified` whenever the source is reconfirmed.
- Do not apply that content-page structure to `docs/index.md`; preserve its VitePress home-page frontmatter.
- Write for architects and developers responsible for shipping compliant solutions. Use active voice, present tense, direct technical language, and exact standards/version names.
- Use `select` rather than `click`, `field` rather than `textbox`, action verbs at the start of procedural steps, and bold formatting for exact UI labels.
- Use `> **Important:**` or `> **Note:**` blockquotes for responsibility statements and easy-to-miss caveats; do not use GitHub alert syntax.
- Use `##` and `###` headings without skipping levels. End actionable guidance with independently verifiable `- [ ]` checklist items.
- Prefer primary sources, relative links for repository pages, and absolute links for external sources. Content pages end with `## Related links`.
- The markdownlint configuration intentionally allows long prose lines and inline HTML. Add repository-specific terms to `cspell.json` instead of altering spelling in technical names.

## Repository conventions

- Use npm and keep `package-lock.json` synchronized with dependency changes.
- Follow Conventional Commits using `<type>(<scope>): <subject>`; the accepted types are documented in `.github/instructions/commit-messages.instructions.md`.
- Keep the root `README.md` as the concise repository overview. Put detailed authoring guidance in `WRITING_STYLE.md` and published documentation in `docs/`.
- When editing `cspell.json`, follow `.github/instructions/sync-cspell.instructions.md`. Run `scripts/sync-cspell.ps1` to sync unknown words rather than editing the `words` list by hand.
- When editing `.github/CODEOWNERS`, follow `.github/instructions/sync-code-owners.instructions.md`. Run `scripts/sync-code-owners.ps1` to sync the `docs/` section rather than editing lines between its `# BEGIN`/`# END AUTO-GENERATED: docs` markers by hand.
- When editing `.github/workflows/*.yml`, follow `.github/instructions/github-actions-node-version.instructions.md`. All actions must run on Node 24; pin actions by SHA with a version comment.
- When implementing a CodeQL workflow or template, follow `.github/instructions/codeql-workflows.instructions.md` for language identifiers, build modes, permissions, runners, and validation.
