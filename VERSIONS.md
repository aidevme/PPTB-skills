# PPTB Skills Versions

Current versions of all skills in the Power Platform Toolbox (PPTB) plugin (`.github/plugins/pptb/skills`). Agents can compare against local versions to check for updates.

| Skill | Version | Last Updated | Status |
| ------- | --------- | --------------- | -------- |
| add-agent-integration | 0.2.0 | 2026-07-27 | Drafted |
| add-dataverse-api | 0.2.0 | 2026-07-27 | Drafted |
| add-error-handling | 0.2.0 | 2026-07-27 | Drafted |
| add-events-api | 0.1.0 | 2026-07-27 | Drafted |
| add-file-system-api | 0.1.0 | 2026-07-27 | Drafted |
| add-host-manager | 0.2.0 | 2026-07-27 | Drafted |
| add-inter-tool-invocation | 0.2.0 | 2026-07-27 | Drafted |
| add-powerplatform-api | 0.2.0 | 2026-07-27 | Drafted |
| add-settings-api | 0.1.0 | 2026-07-27 | Drafted |
| add-toolbox-api | 0.2.0 | 2026-07-27 | Drafted |
| configure-csp | 0.2.0 | 2026-07-27 | Drafted |
| create-pptb-tool | 0.1.0 | 2026-07-23 | Drafted |
| package-toolbox | 0.2.0 | 2026-07-27 | Drafted |
| publish-pptb-tool | 0.2.0 | 2026-07-27 | Drafted |
| setup-toolbox-dev-env | 0.2.0 | 2026-07-27 | Drafted |
| tool-development | 0.1.0 | 2026-07-27 | Drafted |
| toolbox-development | 0.1.0 | 2026-07-27 | Drafted |
| validate-pptb-tool | 0.2.0 | 2026-07-27 | Drafted |

Note: all skills were seeded at 0.1.0 as a starting baseline; skills drafted after that baseline bump to 0.2.0 on their first real content. `add-events-api`, `add-file-system-api`, and `add-settings-api` are new additions (not in the original 13) covering docs pages under `docs/pptb-tools/tool-development/` (`events-api`, `file-system-api`, `settings-api`) that previously had no corresponding skill. `tool-development` and `toolbox-development` are new router/entry-point skills — each with a `references/skills-catalog.md` — that map a generic request to the right specific skill within their audience. All 18 skills now have drafted content; none remain empty scaffolds. Bump each skill's version and Last Updated date here whenever its `SKILL.md` or `references/` content changes.

Total skills: 18

## Recent Changes

### 0.2.0 (2026-07-27) — ToolBox-development group

- Drafted content for `add-host-manager`, `package-toolbox`, and `setup-toolbox-dev-env` — the last 3 empty stubs — grounded in their `docs/pptb-tools/toolbox-development/` reference pages. All 18 skills in the catalog now have drafted content.

### 0.1.0 (2026-07-27)

- Added `tool-development` and `toolbox-development` — router/entry-point skills that map a generic "build a PPTB tool" / "contribute to the ToolBox host" request to the right specific skill, each with a `references/skills-catalog.md` giving full descriptions of every skill in its group.

### 0.2.0 (2026-07-27)

- Drafted content for `add-toolbox-api`, `add-dataverse-api`, `add-error-handling`, `add-powerplatform-api`, `configure-csp`, `validate-pptb-tool`, `add-inter-tool-invocation`, `add-agent-integration`, and `publish-pptb-tool` — all 9 were previously empty stubs, now full specs grounded in their `docs/pptb-tools/tool-development/` reference pages.
- Added three new skills not in the original 13-skill catalog, closing a gap where `docs/pptb-tools/tool-development/{events-api,file-system-api,settings-api}` had no corresponding skill at all: `add-events-api`, `add-file-system-api`, `add-settings-api`.
- Only `add-host-manager`, `package-toolbox`, and `setup-toolbox-dev-env` (the ToolBox-development group) remain empty scaffolds.

### 0.1.0 (2026-07-23)

- Replaced placeholder `VERSIONS.md` content (which listed an unrelated marketing-skills plugin) with the actual PPTB skills inventory from `.github/plugins/pptb/skills`. Seeded all 13 skills at version 0.1.0. Only `create-pptb-tool` has drafted content so far; the remaining 12 are empty scaffolds pending content.
