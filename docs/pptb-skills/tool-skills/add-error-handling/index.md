---
title: add-error-handling
description: Wraps a PPTB tool's API calls in try/catch, adds contextual logging, user-facing notifications, and retry logic for transient failures.
last_verified: 2026-07-22
---

# add-error-handling

This skill retrofits or scaffolds error handling for a PPTB tool. It scans the tool's source for calls into toolbox APIs (Dataverse, file system, connections) that aren't wrapped in `try`/`catch`, then adds handling that logs technical detail for diagnostics while surfacing a short, actionable message to the user through the toolbox notification system.

**Every API call site gets wrapped in `try`/`catch` — the user never sees a raw error or stack trace, only a specific, actionable message.**

## When to use it

- "Add error handling to this tool."
- "Wrap my Dataverse calls in try/catch."
- "This tool crashes silently when a call fails — fix that."
- "Add retry logic for throttled requests."
- After scaffolding a new tool with `create-pptb-tool`, before the tool is considered feature-complete.
- Before running `validate-pptb-tool` or `publish-pptb-tool`, as a pre-publish hardening pass.

## Inputs

- The tool's source files (or a specific file/function) containing unwrapped API calls.
- Whether the operation is a single atomic action (stop-on-first-error) or a batch of independent items (collect-and-continue).
- Which APIs are in play — Dataverse, connection, or file system — since each fails differently.
- Whether transient-failure retry logic is wanted (relevant for Dataverse HTTP calls).

## What it does

1. Scans for API call sites lacking `try`/`catch` and wraps each one.
2. Chooses **stop on first error** (abort and report the single failure) or **collect and continue** (process all items, collect failures, report a summary) based on whether the surrounding operation is atomic or batch.
3. Adds branching on Dataverse HTTP status codes (`400`, `401`, `403`, `404`, `429`, `500`, `503`) mapped to specific, user-friendly messages using the status-code reference table.
4. For connection-dependent calls, inserts an active-connection check before the call instead of letting it fail first.
5. For file system calls, adds handling for missing files and invalid JSON during parsing.
6. Inserts calls to the toolbox notification API using the correct type — success, info, warning, or error — with persistence matched to severity (errors stay visible longer than a transient success toast).
7. Adds `finally` blocks to release any resources acquired before the call.
8. Adds input validation ahead of the API call so invalid input never reaches it.
9. Adds retry logic for transient failures (`429`, `503`) where requested.
10. Ensures logged error output includes contextual information (operation, input, timestamp) without exposing that same detail to the end user.

## Example

Before:

```javascript
async function loadRecord(id) {
  const record = await dataverseAPI.retrieve('account', id);
  return record;
}
```

After:

```javascript
async function loadRecord(id) {
  try {
    if (!hasActiveConnection()) {
      notify.warning('Connect to an environment before loading records.');
      return null;
    }
    const record = await dataverseAPI.retrieve('account', id);
    return record;
  } catch (error) {
    logger.error('loadRecord failed', { id, status: error.status, timestamp: Date.now() });
    if (error.status === 404) {
      notify.error('That record no longer exists.', { persist: true });
    } else if (error.status === 403) {
      notify.error("You don't have permission to view this record.", { persist: true });
    } else {
      notify.error('Could not load the record. Try again.', { persist: true });
    }
    return null;
  } finally {
    setLoading(false);
  }
}
```

## Checklist it enforces

- [ ] Every API call site is wrapped in `try`/`catch`.
- [ ] Errors are logged with enough context (operation, input, timestamp) to diagnose later.
- [ ] User-facing messages are specific and actionable, not raw error dumps.
- [ ] Cleanup logic runs in `finally` blocks regardless of success or failure.
- [ ] Input is validated before it reaches an API call.
- [ ] Transient failures (`429`, `503`) have retry logic.
- [ ] Notification type (success/info/warning/error) matches the severity of the event.

## Related

- [Error Handling](/pptb-tools/tool-development/error-handling/) — the reference this skill is built on
- [validate-pptb-tool](../validate-pptb-tool/) — run after hardening error handling, before publishing
- [publish-pptb-tool](../publish-pptb-tool/) — publishing checklist calls for "proper error handling" as a prerequisite
