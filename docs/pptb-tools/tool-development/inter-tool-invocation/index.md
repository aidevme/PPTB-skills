---
title: Inter-Tool Invocation
description: How one PPTB tool can launch another installed tool, pass it data, and receive a result back.
source: https://docs.powerplatformtoolbox.com/tool-development/inter-tool-invocation
last_verified: 2026-07-22
---

# Inter-Tool Invocation

Inter-Tool Invocation lets any installed PPTB tool launch another installed tool, pre-populate it with data, and optionally receive a result back. Use this when your tool needs a capability another tool already provides — an entity picker, a FetchXML builder — instead of reimplementing it.

**`launchTool()` returns a Promise that resolves with the callee's data when it calls `returnData()`, or `null` if the callee closes without returning anything — and only one callee can be active per caller at a time.**

## Key characteristics

- **Promise-based**: `launchTool()` returns a Promise that resolves when the callee invokes `returnData()`, or resolves to `null` if the callee window is closed without a data return.
- **Isolated execution**: the callee opens in a separate `BrowserView` window and appears as a distinct tab.
- **Automatic closure**: PPTB automatically closes the callee window after `returnData()` executes.
- **Connection inheritance**: the callee automatically inherits the caller's Dataverse connection, unless the caller overrides it.
- **Sequential invocation**: only one active callee is permitted per caller at a time.
- **Optional validation**: data shapes are declared in `pptb.config.json` and validated by `pptb-validate`, but are not enforced at runtime.

## Implementation structure

### Callee role (receiving invocations)

A callee tool declares its invocation contract in `pptb.config.json`, specifying:

- `invocation.version` — the semantic version of the contract.
- `invocation.capabilities` — discoverable capability tags.
- `invocation.prefill` — the expected input data schema.
- `invocation.returnTopic` — the return value schema.

The callee reads any prefill data via `getLaunchContext()` and sends its result back with `returnData()`.

### Caller role (launching tools)

A caller initiates an invocation through `launchTool()`, passing:

- The target tool's ID (its npm package name).
- Optional prefill data.
- Connection overrides and return expectations.

## Discovery mechanism

Tools declare capabilities using tags such as `entity-picker`, `fetchxml`, or `record-selector`. Callers discover matching tools via `findToolsByCapability()`, which lets a caller select a tool dynamically at runtime instead of hardcoding a dependency on a specific tool.

## Data flow

When a caller invokes a tool, PPTB:

1. Validates that the caller doesn't already have an active callee.
2. Creates a new window for the callee.
3. Injects a dismissable "Return to Caller" banner into the callee window.
4. Passes the prefill data to the callee.
5. Resolves the caller's Promise once the callee calls `returnData()` or the callee window closes.

## Publishing requirements

To enable capability discovery, include `pptb.config.json` in your published npm package by adding it to the `files` array in `package.json`.

## Checklist

- [ ] `pptb.config.json` declares `invocation.version`, `invocation.capabilities`, `invocation.prefill`, and `invocation.returnTopic` for any tool acting as a callee.
- [ ] `pptb.config.json` is included in the `files` array in `package.json` so capability discovery works after publishing.
- [ ] Callers handle a `null` resolution from `launchTool()` (the callee closed without returning data).
- [ ] Callers don't attempt to launch a second callee while one is already active.
- [ ] Capability tags used with `findToolsByCapability()` match tags actually declared by target tools.

## Related links

- [Inter-Tool Invocation (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/inter-tool-invocation)
- [Tool Development](/pptb-tools/tool-development/)
- [Agent Integration](/pptb-tools/tool-development/agent-integration/)
