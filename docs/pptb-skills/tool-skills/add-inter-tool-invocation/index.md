---
title: add-inter-tool-invocation
description: Wires up a PPTB tool as a caller, a callee, or both, so it can launch another installed tool and exchange data with it.
last_verified: 2026-07-22
---

# add-inter-tool-invocation

This skill adds Inter-Tool Invocation support to a PPTB tool — either the caller side (launch another tool and get data back), the callee side (declare a contract so another tool can launch this one), or both. It generates the `pptb.config.json` invocation contract, the code that reads prefill data or returns a result, and the caller-side `launchTool()` / `findToolsByCapability()` calls, so a tool can reuse another tool's capability (an entity picker, a FetchXML builder) instead of reimplementing it.

**`launchTool()` returns a Promise that resolves with the callee's data when it calls `returnData()`, or `null` if the callee closes without returning anything — and only one callee can be active per caller at a time.**

## When to use it

- "Let this tool launch the entity picker tool and get the selected record back."
- "Make my tool discoverable as a FetchXML builder other tools can launch."
- "Add an invocation contract to pptb.config.json."
- "My tool needs to reuse another installed tool's picker instead of building its own."
- Alongside `add-agent-integration`, since the invocation contract layer is shared between inter-tool invocation and MCP agent exposure.

## Inputs

- Whether the tool acts as a caller, a callee, or both.
- For a callee: the capability tags to advertise (e.g. `entity-picker`, `fetchxml`, `record-selector`), the expected prefill input shape, and the return value shape.
- For a caller: the target tool's npm package name (or a capability tag to discover it dynamically), any prefill data to pass, and whether to override the inherited Dataverse connection.

## What it does

1. For a callee, adds an `invocation` object to `pptb.config.json` with `invocation.version` (semantic version of the contract), `invocation.capabilities` (discoverable tags), `invocation.prefill` (expected input schema), and `invocation.returnTopic` (return value schema).
2. Generates callee-side code that reads incoming data via `getLaunchContext()` and sends its result back with `returnData()`.
3. Adds `pptb.config.json` to the `files` array in `package.json` so capability discovery works once the tool is published — invocation contracts aren't discoverable otherwise.
4. For a caller, generates a `launchTool()` call that passes the target tool's ID (its npm package name), optional prefill data, and any connection overrides.
5. Where the caller should discover a tool dynamically rather than hardcode a dependency, generates a `findToolsByCapability()` call against the relevant capability tag.
6. Adds handling for the caller side that treats a `null` Promise resolution as "the callee closed without returning data" — not an error.
7. Guards against launching a second callee while one is already active, since only one callee can be active per caller at a time.
8. Reminds the developer that `pptb-validate` checks the declared data shapes but does not enforce them at runtime, so callee code must still validate incoming `getLaunchContext()` data defensively.

## Example

Callee contract added to `pptb.config.json`:

```json
{
  "invocation": {
    "version": "1.0.0",
    "capabilities": ["entity-picker", "record-selector"],
    "prefill": { "entityName": "string", "filter": "string?" },
    "returnTopic": { "recordId": "string", "entityName": "string" }
  }
}
```

Caller code generated to launch it:

```javascript
const result = await toolboxAPI.launchTool('@my-org/entity-picker', {
  prefill: { entityName: 'account' },
});

if (result === null) {
  // Callee window closed without calling returnData() — not an error.
  return;
}

console.log(result.recordId, result.entityName);
```

## Checklist it enforces

- [ ] `pptb.config.json` declares `invocation.version`, `invocation.capabilities`, `invocation.prefill`, and `invocation.returnTopic` for any tool acting as a callee.
- [ ] `pptb.config.json` is included in the `files` array in `package.json` so capability discovery works after publishing.
- [ ] Callers handle a `null` resolution from `launchTool()` (the callee closed without returning data).
- [ ] Callers don't attempt to launch a second callee while one is already active.
- [ ] Capability tags used with `findToolsByCapability()` match tags actually declared by target tools.

## Related

- [Inter-Tool Invocation](/pptb-tools/tool-development/inter-tool-invocation/) — the reference this skill is built on
- [add-agent-integration](../add-agent-integration/) — builds on the same invocation contract for MCP/agent exposure
- [add-error-handling](../add-error-handling/) — apply to caller/callee code so a failed launch or malformed return data degrades gracefully
