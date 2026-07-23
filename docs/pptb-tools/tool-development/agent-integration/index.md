---
title: Agent Integration
description: How a PPTB tool exposes itself to AI assistants through the toolbox's built-in MCP server.
source: https://docs.powerplatformtoolbox.com/tool-development/agent-integration
last_verified: 2026-07-22
---

# Agent Integration

Power Platform ToolBox lets tool developers expose selected tools to AI assistants through its built-in MCP server. As the developer, you control whether your tool is discoverable by an agent, what input it accepts, what results it returns, and whether it supports interactive use, automated (headless) use, or both.

**Agent integration is three steps: declare an invocation contract, mark the tool as invokable by agents, and — if you want automated (non-UI) execution — add a headless runtime entry point.**

## MCP contract layers

The contract that governs agent integration has two distinct layers:

- **Invocation layer** — describes the input payload and the structured result, the same contract used by [inter-tool invocation](/pptb-tools/tool-development/inter-tool-invocation/).
- **Agents layer** — declares the tool's availability to AI assistants and its MCP behavior.

## Execution styles

| User-facing term | MCP value | Purpose |
| --- | --- | --- |
| Interactive tool run | `executionMode: "windowed"` | PPTB opens the tool's UI |
| Automated tool run | `executionMode: "headless"` | PPTB runs the tool without a UI |

## Configuration requirements

Add `invocation` and `agents` objects to `pptb.config.json`. Key `agents` fields:

- `invokable` — exposes the tool through MCP discovery.
- `modes` — supports `"one-way"` (fire-and-forget) or `"two-way"` (result-returning).
- `executionModes` — lists which execution modes the tool supports.
- `headlessEntry` — points to the automated runtime's entry point.
- `timeoutMS` — a timeout hint for result-returning calls.

## Automated runtime

For headless execution, export an `invokeHeadless(input, context)` function from a discoverable file. PPTB resolves the entry point in this order:

1. The path specified in `agents.headlessEntry`.
2. `dist/headless.js`.
3. `headless.js`.
4. `package.json`'s `main` field.

## Design principles

For a tool that supports both interactive and automated execution:

- Accept identical input shapes across the UI path and the automated path.
- Return consistent result shapes regardless of which execution method was used.
- Treat automated runs as task-oriented operations, not as a scripted UI session.
- Use progress updates and structured logging so an agent (and a human debugging it) can follow what happened.
- Exclude secrets from logs and payloads.

## Validation steps

Before publishing a tool with agent integration:

1. Validate the configuration locally.
2. Confirm MCP discovery behavior — the tool shows up where it should.
3. Test both call modes (interactive and, if supported, headless).
4. Verify the automated runtime's payload matches the declared `returnTopic`.
5. Use the MCP Inspector for manual testing.

## Checklist

- [ ] `pptb.config.json` declares both an `invocation` object and an `agents` object.
- [ ] `agents.invokable` is set intentionally — `true` only for tools meant to be agent-discoverable.
- [ ] `agents.executionModes` accurately lists the modes the tool actually supports.
- [ ] If headless execution is supported, `invokeHeadless(input, context)` is exported and resolvable via `headlessEntry`, `dist/headless.js`, `headless.js`, or `package.json.main` (in that order).
- [ ] Input/output shapes are identical (or documented as equivalent) across windowed and headless execution.
- [ ] No secrets appear in logs or payloads.
- [ ] The tool has been tested with the MCP Inspector before publishing.

## Related links

- [Agent Integration (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/agent-integration)
- [Tool Development](/pptb-tools/tool-development/)
- [Inter-Tool Invocation](/pptb-tools/tool-development/inter-tool-invocation/)
