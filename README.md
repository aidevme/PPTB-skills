# PPTB skills for PPTB ToolBox and PPTB Tools

![PPTB Skills social preview](assets/pptb-skill-social-preview.png)

A curated library of reusable development skills, patterns, and best practices for building plugins and tools within the Power Platform Toolbox (PPTB) ecosystem — covering plugin architecture, Dataverse integration, PCF controls, rule-engine design, and Azure-hosted backends.

## What are Skills?

Skills are markdown files that give AI agents specialized knowledge and workflows for specific tasks. When you add these to your project, your agent can recognize when you're working on a marketing task and apply the right frameworks and best practices.

## How Skills Work Together

## Available Skills

<!-- SKILLS:START -->
| Skill                                                             | Description                                                                                                                                                                                          |
|-------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [create-pptb-tool](.github/plugins/pptb/skills/create-pptb-tool/) | Scaffolds a new Power Platform ToolBox (PPTB) tool — runs the `yo pptb` generator (or a manual fallback), writes a compliant `package.json` manifest, installs `@pptb/types`, and wires a minimal... |
<!-- SKILLS:END -->

> 12 additional skills (`add-agent-integration`, `add-dataverse-api`, `add-error-handling`, `add-host-manager`, `add-inter-tool-invocation`, `add-powerplatform-api`, `add-toolbox-api`, `configure-csp`, `package-toolbox`, `publish-pptb-tool`, `setup-toolbox-dev-env`, `validate-pptb-tool`) are specified but not yet implemented — see [VERSIONS.md](VERSIONS.md) for status and [docs/pptb-skills](docs/pptb-skills/) for their design specs.
