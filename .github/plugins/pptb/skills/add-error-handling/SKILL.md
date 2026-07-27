---
name: add-error-handling
description: Wraps a PPTB tool's `toolboxAPI`/`dataverseAPI`/`powerplatformAPI`/file-system calls in `try`/`catch`, adds contextual logging, user-facing notifications, and retry logic for transient failures. Use when asked to "add error handling to this tool", "wrap my Dataverse calls in try/catch", "this tool crashes silently when a call fails", "add retry logic for throttled requests", or as a pre-publish hardening pass after `create-pptb-tool` and before `validate-pptb-tool`/`publish-pptb-tool`.
---

# Add Error Handling

An unhandled rejection or a raw stack trace shown to the user degrades trust in the whole ToolBox host, not just the one tool that caused it. This skill retrofits or scaffolds error handling for a PPTB tool: it finds calls into `toolboxAPI`, `dataverseAPI`, `powerplatformAPI`, or the File System API that aren't wrapped, then adds handling that logs the technical detail for diagnostics while showing the user a short, actionable message instead.

**Every API call site gets wrapped in `try`/`catch` — the user never sees a raw error or stack trace, only a specific, actionable message; the technical detail goes to `console.error`/a logger, not to the notification shown to the user.**

## Step 1: Choose a failure strategy per operation

Before wrapping anything, decide how the surrounding operation should behave on failure:

- **Stop on first error** — abort as soon as one call fails, report that single failure. Use this for a single atomic action (e.g. saving one record).
- **Collect and continue** — keep processing remaining items, collect failures, report a summary at the end. Use this for a batch of independent items (e.g. importing 200 rows, some of which may fail without blocking the rest).

Pick based on whether the operation is atomic or a batch — don't default to one strategy for every call site in the tool.

## Step 2: Guard connection-dependent calls before they run

For any `dataverseAPI`/`powerplatformAPI` call, check that an active connection exists first rather than letting the call fail and parsing the failure afterward:

```typescript
const connection = await toolboxAPI.connections.getActiveConnection()

if (!connection) {
  await toolboxAPI.utils.showNotification({
    title: 'No connection',
    body: 'Connect to an environment before loading records.',
    type: 'warning',
    duration: 0,
  })
  return null
}
```

For `powerplatformAPI` specifically, also check `connection.enabledForPowerPlatformAPI` before the call (see `add-powerplatform-api`) — the same "check before calling" principle applies.

## Step 3: Wrap the call in `try`/`catch` and branch on status code

Dataverse (and other HTTP-based) errors carry a status code — branch on it to give specific, actionable guidance instead of one generic message:

| Status code | Typical meaning | Example user-facing message |
| --- | --- | --- |
| 400 | Bad request — invalid input | "Check the values you entered and try again." |
| 401 | Not authenticated | "Your session has expired — reconnect and try again." |
| 403 | Forbidden — insufficient privileges | "You don't have permission to do this." |
| 404 | Not found | "That record no longer exists." |
| 429 | Too many requests — throttled | "Too many requests — retrying automatically." (see Step 6) |
| 500 | Server error | "Something went wrong on the server. Try again shortly." |
| 503 | Service unavailable | "The service is temporarily unavailable. Try again shortly." |

```typescript
try {
  const record = await dataverseAPI.retrieve('account', id, ['name'])
  return record
} catch (error) {
  console.error('loadRecord failed', { id, status: error?.status, timestamp: Date.now() })

  const message =
    error?.status === 404 ? 'That record no longer exists.'
    : error?.status === 403 ? "You don't have permission to view this record."
    : error?.status === 401 ? 'Your session has expired — reconnect and try again.'
    : 'Could not load the record. Try again.'

  await toolboxAPI.utils.showNotification({ title: 'Error', body: message, type: 'error', duration: 0 })
  return null
}
```

## Step 4: Handle file system errors

`toolboxAPI.fileSystem` operations need two failure modes covered explicitly, not just a generic catch: the file may not exist, and its contents may not parse as valid JSON. Check existence with `exists()` before reading — per the File System API's own guidance — rather than relying on the read call's rejection to tell you the file was missing, and catch JSON parsing separately from the read itself:

```typescript
if (!(await toolboxAPI.fileSystem.exists(path))) {
  await toolboxAPI.utils.showNotification({
    title: 'File not found',
    body: `Could not find ${path}.`,
    type: 'error',
  })
  return null
}

try {
  const raw = await toolboxAPI.fileSystem.readText(path)
  try {
    return JSON.parse(raw)
  } catch {
    await toolboxAPI.utils.showNotification({
      title: 'Invalid file',
      body: `${path} isn't valid JSON.`,
      type: 'error',
    })
    return null
  }
} catch (error) {
  console.error('readConfig failed', { path, error })
  await toolboxAPI.utils.showNotification({ title: 'Error', body: 'Could not read the file.', type: 'error' })
  return null
}
```

## Step 5: Match notification type and persistence to severity

Use `toolboxAPI.utils.showNotification({ title, body, type, duration })` with one of four types, and set `duration` (milliseconds, `0` = persistent) to match how long the message needs to stay visible:

- **`success`** — operation completed; short `duration` (e.g. `3000`) is fine.
- **`info`** — informational, non-blocking; short `duration`.
- **`warning`** — didn't stop the operation, but the user should notice; longer `duration` or `0`.
- **`error`** — the operation failed; typically `duration: 0` (persistent) so the user doesn't miss it.

## Step 6: Add retry logic for transient failures

Retry `429`/`503` responses with backoff rather than surfacing them as a hard failure immediately — these are typically transient:

```typescript
async function withRetry<T>(fn: () => Promise<T>, maxAttempts = 3): Promise<T> {
  for (let attempt = 1; ; attempt++) {
    try {
      return await fn()
    } catch (error: any) {
      const transient = error?.status === 429 || error?.status === 503
      if (!transient || attempt >= maxAttempts) throw error
      await new Promise((resolve) => setTimeout(resolve, 2 ** attempt * 500))
    }
  }
}

const result = await withRetry(() => dataverseAPI.fetchXmlQuery(fetchXml))
```

Don't retry non-transient failures (`400`, `401`, `403`, `404`) — retrying a request that will always fail the same way just delays the error message the user needs to see.

## Step 7: Validate input before the call, and clean up in `finally`

Check inputs are well-formed before they reach an API call — an early, specific validation message beats a `400` from the server three network hops later. Release any resources acquired before the call (loading spinners, terminal sessions, open handles) in a `finally` block so they're released whether the call succeeds or fails:

```typescript
async function saveRecord(id: string, values: Record<string, unknown>) {
  if (!id) {
    await toolboxAPI.utils.showNotification({ title: 'Missing ID', body: 'No record selected.', type: 'warning' })
    return
  }

  setLoading(true)
  try {
    await dataverseAPI.update('account', id, values)
    await toolboxAPI.utils.showNotification({ title: 'Saved', body: 'Record updated.', type: 'success', duration: 3000 })
  } catch (error) {
    console.error('saveRecord failed', { id, error })
    await toolboxAPI.utils.showNotification({ title: 'Error', body: 'Could not save the record.', type: 'error', duration: 0 })
  } finally {
    setLoading(false)
  }
}
```

## Checklist

- [ ] Every API call site is wrapped in `try`/`catch`.
- [ ] Errors are logged with enough context (operation, input, timestamp) to diagnose later — but that same detail never reaches the user-facing notification.
- [ ] User-facing messages are specific and actionable, not raw error dumps.
- [ ] Connection-dependent calls check for an active connection before calling, rather than parsing the failure afterward.
- [ ] Cleanup logic runs in `finally` blocks regardless of success or failure.
- [ ] Input is validated before it reaches an API call.
- [ ] Transient failures (`429`, `503`) have retry logic; non-transient failures (`400`, `401`, `403`, `404`) don't retry.
- [ ] Notification type (`success`/`info`/`warning`/`error`) and `duration` match the severity of the event.

## Next steps

- `add-toolbox-api` / `add-dataverse-api` / `add-powerplatform-api` / `add-file-system-api` — the call sites this skill wraps
- `validate-pptb-tool` — run after hardening error handling, before publishing
- `publish-pptb-tool` — publishing checklist calls for proper error handling as a prerequisite
