---
title: add-agent-integration
description: Declares an invocation contract, exposes a PPTB tool to AI assistants through the toolbox's MCP server, and adds a headless entry point for automated runs.
last_verified: 2026-07-22
---

# add-agent-integration

This skill exposes a PPTB tool to AI assistants through the toolbox's built-in MCP server. It configures the `agents` layer in `pptb.config.json` on top of the tool's existing (or newly added) `invocation` contract, and — when the tool should run without a UI — scaffolds an `invokeHeadless(input, context)` entry point so an agent can drive the tool without opening its window.

**Agent integration is three steps: declare an invocation contract, mark the tool as invokable by agents, and — if you want automated (non-UI) execution — add a headless runtime entry point.**

## When to use it

- "Make this tool callable by Claude/an AI assistant through MCP."
- "Add headless execution so an agent can run this tool without opening the UI."
- "Expose this tool for automated, one-way agent calls."
- "My tool already supports inter-tool invocation — now let agents call it too."
- After `add-inter-tool-invocation`, since the agents layer sits on top of the same invocation contract.

## Inputs

- Whether the tool should be agent-discoverable at all (`agents.invokable`).
- Which execution modes to support: `"windowed"` (PPTB opens the tool's UI) and/or `"headless"` (PPTB runs the tool without a UI).
- Whether calls are `"one-way"` (fire-and-forget) or `"two-way"` (result-returning), and a `timeoutMS` hint for the latter.
- The location of the headless entry point, if not left to the default resolution order.
- Whether an `invocation` contract (`prefill`/`returnTopic`) already exists on the tool, or needs to be added first.

## What it does

1. Adds (or confirms) the `invocation` object in `pptb.config.json` — the same contract layer used by inter-tool invocation — describing the input payload and structured result.
2. Adds an `agents` object to `pptb.config.json` with `invokable: true` (only when the tool is meant to be agent-discoverable), `modes` (`"one-way"` and/or `"two-way"`), `executionModes` (the actual supported modes), and `timeoutMS` for result-returning calls.
3. If headless execution is requested, scaffolds and exports an `invokeHeadless(input, context)` function, and sets `agents.headlessEntry` to point at it.
4. Confirms the headless entry point is resolvable in PPTB's lookup order: `agents.headlessEntry` first, then `dist/headless.js`, then `headless.js`, then `package.json`'s `main` field.
5. Aligns input/output shapes between the windowed (UI) path and the headless path so an agent and a human get equivalent results from equivalent input.
6. Adds progress updates and structured logging in the headless path so an agent (and a human debugging it) can follow execution.
7. Checks that no secrets appear in logs or in the headless input/output payloads.
8. Prompts the pre-publish validation sequence: validate configuration locally, confirm MCP discovery shows the tool where expected, test both call modes, verify the headless payload matches the declared `returnTopic`, and exercise the tool with the MCP Inspector.

## Example

`pptb.config.json` additions:

```json
{
  "invocation": {
    "version": "1.0.0",
    "prefill": { "entityName": "string" },
    "returnTopic": { "recordCount": "number", "records": "array" }
  },
  "agents": {
    "invokable": true,
    "modes": ["two-way"],
    "executionModes": ["windowed", "headless"],
    "headlessEntry": "dist/headless.js",
    "timeoutMS": 15000
  }
}
```

Headless entry point:

```javascript
// dist/headless.js
export async function invokeHeadless(input, context) {
  const { entityName } = input;
  context.log(`Querying ${entityName}...`);
  const records = await context.dataverseAPI.retrieveMultiple(entityName);
  return { recordCount: records.length, records };
}
```

## Checklist it enforces

- [ ] `pptb.config.json` declares both an `invocation` object and an `agents` object.
- [ ] `agents.invokable` is set intentionally — `true` only for tools meant to be agent-discoverable.
- [ ] `agents.executionModes` accurately lists the modes the tool actually supports.
- [ ] If headless execution is supported, `invokeHeadless(input, context)` is exported and resolvable via `headlessEntry`, `dist/headless.js`, `headless.js`, or `package.json.main` (in that order).
- [ ] Input/output shapes are identical (or documented as equivalent) across windowed and headless execution.
- [ ] No secrets appear in logs or payloads.
- [ ] The tool has been tested with the MCP Inspector before publishing.

## Related

- [Agent Integration](/pptb-tools/tool-development/agent-integration/) — the reference this skill is built on
- [add-inter-tool-invocation](../add-inter-tool-invocation/) — supplies the shared `invocation` contract layer
- [publish-pptb-tool](../publish-pptb-tool/) — run after agent integration is validated, before publishing
