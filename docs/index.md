---
title: PPTB Skills
description: A curated library of reusable development skills, patterns, and best practices for building plugins and tools within the Power Platform Toolbox (PPTB) ecosystem.
last_verified: 2026-07-22
---

# PPTB Skills

This site documents reusable skills, patterns, and best practices for building plugins and tools within the Power Platform Toolbox (PPTB) ecosystem. It's written for developers building or maintaining a PPTB plugin — someone who already knows the Power Platform and needs concrete guidance on plugin architecture, Dataverse integration, PCF controls, rule-engine design, and Azure-hosted backends.

**These pages capture patterns that work — applying them correctly to your specific plugin, and keeping them current as PPTB evolves, is still your responsibility.**

## What this library covers

### Plugin architecture

Structuring a PPTB plugin: module boundaries, extension points, and how a plugin registers itself with the toolbox host.

### Dataverse integration

Patterns for connecting a plugin to Dataverse — authentication, querying, and keeping plugin state in sync with environment data.

### PCF controls

Building and packaging Power Apps Component Framework controls that a PPTB plugin can host or embed.

### Rule-engine design

Designing configurable rule engines within a plugin, so behavior can be adjusted without code changes.

### Azure-hosted backends

Patterns for plugins that need a backend service — hosting, authentication, and calling that service securely from the toolbox.

## Related links

- [PPTB-skills on GitHub](https://github.com/aidevme/PPTB-skills) — source repository for this site.
- [Writing Style Guide](https://github.com/aidevme/PPTB-skills/blob/main/WRITING_STYLE.md) — conventions used to write these pages.
