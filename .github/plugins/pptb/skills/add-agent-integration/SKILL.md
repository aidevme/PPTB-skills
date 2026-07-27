---
name: add-agent-integration
description: Exposes a PPTB tool to AI assistants through the ToolBox's built-in MCP server — declaring the `agents` object in `pptb.config.json`, choosing interactive vs. automated execution, and adding a headless `invokeHeadless(input, context)` entry point. Use when asked to "make this tool available to AI assistants", "expose my tool via MCP", "add headless/automated execution to my tool", "let an agent invoke this tool without opening the UI", or "why isn't my tool showing up for MCP discovery".
---

# Add Agent Integration

Power Platform ToolBox lets a tool developer expose selected tools to AI assistants through its built-in MCP server. This skill wires up that exposure: whether the tool is agent-discoverable at all, what input/output shape it declares, and whether it supports interactive (UI) use, automated (headless) use, or both.

**Agent integration is three steps: declare an invocation contract, mark the tool as invokable by agents, and — only if automated (non-UI) execution is wanted — add a headless runtime entry point. Don't skip straight to `headlessEntry` without the invocation contract underneath it; the MCP layer builds on the same contract `add-inter-tool-invocation` uses.**

## Step 1: Declare the invocation contract (shared with inter-tool invocation)

The MCP contract has two layers. The invocation layer — input payload and structured result — is the *same* contract `add-inter-tool-invocation` declares in `pptb.config.json`. If the tool doesn't already have `invocation.prefill`/`invocation.returnTopic` declared, add them first (see that skill) before layering the agents-specific fields on top.

## Step 2: Declare the `agents` object

Add an `agents` object alongside `invocation` in `pptb.config.json`:

```json
{
  "invocation": {
    "version": "1.0.0",
    "prefill": { "entityName": "string" },
    "returnTopic": { "recordId": "string" }
  },
  "agents": {
    "invokable": true,
    "modes": ["two-way"],
    "executionModes": ["windowed", "headless"],
    "headlessEntry": "dist/headless.js",
    "timeoutMS": 30000
  }
}
```

| Field | Meaning |
| --- | --- |
| `invokable` | Whether the tool is exposed through MCP discovery at all — set `true` only for tools genuinely meant to be agent-discoverable |
| `modes` | `"one-way"` (fire-and-forget) or `"two-way"` (result-returning) |
| `executionModes` | Which execution styles the tool supports — `"windowed"` (PPTB opens the UI) and/or `"headless"` (no UI) |
| `headlessEntry` | Entry-point file for automated runtime, only relevant if `"headless"` is in `executionModes` |
| `timeoutMS` | Timeout hint for result-returning calls |

Set `executionModes` to accurately reflect what the tool actually supports — don't list `"headless"` unless Step 3 is also done.

## Step 3: Add the headless entry point (only if `executionModes` includes `"headless"`)

Export an `invokeHeadless(input, context)` function from a discoverable file. PPTB resolves the entry point in this order:

1. The path in `agents.headlessEntry`.
2. `dist/headless.js`.
3. `headless.js`.
4. `package.json`'s `main` field.

```typescript
export async function invokeHeadless(input: Record<string, unknown>, context: unknown) {
  // Treat this as a task-oriented operation, not a scripted UI session —
  // no DOM, no user interaction, just input in, structured result out.
  const result = await performOperation(input)
  return result
}
```

Match `invokeHeadless`'s input/output shape to `invocation.prefill`/`invocation.returnTopic` exactly (or document any deliberate difference) — an agent calling headlessly and a user calling through the UI should get consistent results either way.

## Step 4: Follow the design principles for dual-mode tools

For a tool supporting both interactive and automated execution:

- Accept identical input shapes across the UI path and the headless path.
- Return consistent result shapes regardless of which execution method was used.
- Use progress updates and structured logging so an agent — and a human debugging it — can follow what happened, since there's no UI to watch.
- Exclude secrets from logs and payloads; a headless invocation's input/output may be logged for debugging, so nothing sensitive should ever pass through it.

## Step 5: Validate before publishing

1. Validate the configuration locally (see `validate-pptb-tool`).
2. Confirm MCP discovery behavior — the tool shows up where it should, and doesn't show up when `invokable: false`.
3. Test both call modes if both are declared — interactive and headless.
4. Verify the headless runtime's actual output matches the declared `returnTopic`.
5. Use the MCP Inspector for manual testing before submitting to the registry.

## Checklist

- [ ] `pptb.config.json` declares both an `invocation` object and an `agents` object.
- [ ] `agents.invokable` is set intentionally — `true` only for tools meant to be agent-discoverable.
- [ ] `agents.executionModes` accurately lists the modes the tool actually supports.
- [ ] If headless execution is supported, `invokeHeadless(input, context)` is exported and resolvable via `headlessEntry`, `dist/headless.js`, `headless.js`, or `package.json.main` (in that order).
- [ ] Input/output shapes are identical (or documented as equivalent) across windowed and headless execution.
- [ ] No secrets appear in logs or payloads.
- [ ] The tool has been tested with the MCP Inspector before publishing.

## Next steps

- `add-inter-tool-invocation` — the shared invocation contract layer this skill builds on
- `add-error-handling` — headless execution has no UI to surface errors through, so structured error results matter even more here
- `validate-pptb-tool` / `publish-pptb-tool` — finish the pre-publish workflow once agent integration is wired up
