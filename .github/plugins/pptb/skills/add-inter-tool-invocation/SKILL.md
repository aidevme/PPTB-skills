---
name: add-inter-tool-invocation
description: Wires up a PPTB tool as a caller, a callee, or both, so it can launch another installed tool and exchange data with it — the `pptb.config.json` invocation contract plus the `toolboxAPI.invocation.launchTool()`/`getLaunchContext()`/`returnData()` calls. Use when asked to "let this tool launch the entity picker and get the selected record back", "make my tool discoverable as a FetchXML builder", "add an invocation contract to pptb.config.json", or "my tool needs to reuse another installed tool's picker instead of building its own".
---

# Add Inter-Tool Invocation

Inter-Tool Invocation lets one installed PPTB tool launch another, pre-populate it with data, and optionally receive a result back — so a tool can reuse another tool's capability (an entity picker, a FetchXML builder) instead of reimplementing it. This skill wires up the caller side, the callee side, or both, plus the `pptb.config.json` contract that makes a callee discoverable.

**`launchTool()` returns a Promise that resolves with the callee's data when it calls `returnData()`, or `null` if the callee closes without returning anything — and only one callee can be active per caller at a time.**

## Step 1: Determine the tool's role

- **Callee** — the tool being launched by another tool. Go to Step 2.
- **Caller** — the tool launching another tool. Go to Step 3.
- **Both** — some tools act as a callee for one workflow and a caller for another; do both steps.

## Step 2: Wire the callee side

Declare the invocation contract in `pptb.config.json`:

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

- `version` — semantic version of the contract itself, bumped when the shape changes.
- `capabilities` — discoverable tags other tools can search for via `findToolsByCapability()`.
- `prefill` — the expected shape of the input data a caller may pass in.
- `returnTopic` — the shape of the result this tool sends back.

Read the incoming prefill data with `getLaunchContext()` (returns `null` if the tool wasn't launched via invocation — always handle that case, since the tool can still be opened normally), and send the result back with `returnData()`:

```typescript
const ctx = await toolboxAPI.invocation.getLaunchContext()

if (ctx) {
  // Pre-populate UI from ctx.entityName, ctx.filter, etc.
}

// After the user makes a selection:
await toolboxAPI.invocation.returnData({
  recordId: 'guid-here',
  entityName: 'account',
})
```

`pptb-validate` checks that the declared shapes are well-formed, but does not enforce them at runtime — validate incoming `getLaunchContext()` data defensively rather than trusting it matches `prefill` exactly.

Include `pptb.config.json` in the `files` array in `package.json` — capability discovery doesn't work after publishing otherwise:

```json
{
  "files": ["dist", "pptb.config.json"]
}
```

## Step 3: Wire the caller side

Launch a known tool directly by its npm package name (its `toolId`):

```typescript
const result = await toolboxAPI.invocation.launchTool('@my-org/entity-picker', {
  entityName: 'account',
})

if (result === null) {
  // Callee window closed without calling returnData() — not an error.
  return
}

console.log(result.recordId, result.entityName)
```

`launchTool(targetToolId, prefillData?, options?)` accepts `options: { primaryConnectionId?, secondaryConnectionId? }` to override which connections the launched tool opens with — otherwise the callee inherits the caller's connection automatically.

Where the target shouldn't be hardcoded, discover it dynamically by capability tag instead:

```typescript
const candidates = await toolboxAPI.invocation.findToolsByCapability('entity-picker')
```

## Step 4: Handle the `null` and single-active-callee cases

Always branch on a `null` result from `launchTool()` as "the user closed the callee without returning data," not as an error condition — don't log it or surface an error notification for it. Also guard against launching a second callee while one is already active per caller; only one is permitted at a time, so check state before calling `launchTool()` again.

## Checklist

- [ ] `pptb.config.json` declares `invocation.version`, `invocation.capabilities`, `invocation.prefill`, and `invocation.returnTopic` for any tool acting as a callee.
- [ ] `pptb.config.json` is included in the `files` array in `package.json` so capability discovery works after publishing.
- [ ] Callers handle a `null` resolution from `launchTool()` (the callee closed without returning data) without treating it as an error.
- [ ] Callers don't attempt to launch a second callee while one is already active.
- [ ] Capability tags used with `findToolsByCapability()` match tags actually declared by target tools.
- [ ] Callee code validates incoming `getLaunchContext()` data defensively rather than trusting it matches `prefill` exactly.

## Next steps

- `add-toolbox-api` — for the simpler direct `launchTool()`/`getLaunchContext()`/`returnData()` calls without a discoverable capability contract
- `add-agent-integration` — builds on this same invocation contract layer for MCP/agent exposure
- `add-error-handling` — apply to caller/callee code so a failed launch or malformed return data degrades gracefully
