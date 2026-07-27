---
title: Overview
description: A standardized way to give AI agents new capabilities and expertise.
source: https://agentskills.io/home
last_verified: 2026-07-27
---

# Agent Skills Overview

A standardized way to give AI agents new capabilities and expertise.

## What are Agent Skills?

Agent Skills are a lightweight, open format for extending AI agent capabilities with specialized knowledge and workflows.

At its core, a skill is a folder containing a `SKILL.md` file. This file includes metadata (name and description, at minimum) and instructions that tell an agent how to perform a specific task. Skills can also bundle scripts, reference materials, templates, and other resources.

```text
my-skill/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

## Why Agent Skills?

Agents are increasingly capable, but often don't have the context they need to do real work reliably. Skills solve this by packaging procedural knowledge and company-, team-, and user-specific context into portable, version-controlled folders that agents load on demand. This gives agents:

- **Domain expertise** — capture specialized knowledge — from legal review processes to data analysis pipelines to presentation formatting — as reusable instructions and resources.
- **Repeatable workflows** — turn multi-step tasks into consistent, auditable procedures.
- **Cross-product reuse** — build a skill once and use it across any skills-compatible agent.

## How do Agent Skills work?

Agents load skills through progressive disclosure, in three stages:

1. **Discovery** — at startup, agents load only the name and description of each available skill, just enough to know when it might be relevant.
2. **Activation** — when a task matches a skill's description, the agent reads the full `SKILL.md` instructions into context.
3. **Execution** — the agent follows the instructions, optionally executing bundled code or loading referenced files as needed.

Full instructions load only when a task calls for them, so agents can keep many skills on hand with only a small context footprint.

## Where can I use Agent Skills?

Agent Skills are supported by a large number of AI tools and agentic clients — see [Client Showcase](/miscellaneous/agent-skills/client-showcase/) to explore some of them:

Junie, ZeroClaw, Gemini CLI, Autohand Code CLI, OpenCode, OpenHands, Mux, Cursor, Amp, Letta, Firebender, Goose, GitHub Copilot, VS Code, Claude Code, Claude, OpenAI Codex, Piebald, Factory, pi, Databricks Genie Code, Agentman, TRAE, Spring AI, Roo Code, Mistral AI Vibe, Command Code, Ona, VT Code, Qodo, Laravel Boost, Emdash, Snowflake Cortex Code, Kiro, Workshop, Google AI Edge Gallery, nanobot, fast-agent, bub, Tabnine, Vita, Superconductor, Deep Code, Pulumi Neo.

## Open development

The Agent Skills format was originally developed by [Anthropic](https://www.anthropic.com/), released as an open standard, and has been adopted by a growing number of agent products. The standard is open to contributions from the broader ecosystem.

Come join the discussion on [GitHub](https://github.com/agentskills/agentskills) or [Discord](https://discord.gg/MKPE9g8aUy)!

## Get started with Agent Skills

- **[Quickstart](/miscellaneous/agent-skills/quickstart/)** — create your first Agent Skill and see it in action.
- **[Specification](/miscellaneous/agent-skills/specification/)** — the complete format specification for Agent Skills.
