---
title: Error Handling
description: Conventions a PPTB tool should follow for surfacing and recovering from API failures.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/error-handling
last_verified: 2026-07-22
---

# Error Handling

This page covers how a PPTB tool should handle failures from the various toolbox APIs (Dataverse, file system, connections, and so on). Getting this right matters: a tool that lets an unhandled rejection propagate, or that shows a raw stack trace to the user, degrades trust in the whole toolbox — not just your tool.

**All API calls may throw errors — always wrap them in `try`/`catch`, log the technical detail for diagnostics, and show the user a short, actionable message instead of the raw error.**

## Basic error handling

Wrap API calls in `try`/`catch` blocks and notify the user of failures. There are two common approaches:

- **Stop on first error** — abort the operation as soon as a call fails, and report that single failure to the user.
- **Collect and continue** — keep processing remaining items, collecting failures, and report a summary at the end.

Choose based on whether the operation is a single atomic action or a batch of independent items.

## API-specific errors

Different APIs fail in different ways, and your handling should reflect that:

- **Dataverse errors** carry HTTP status codes such as `404`, `403`, and `401` — branch on these to give specific guidance (record not found, insufficient privileges, not authenticated).
- **Connection errors** should check whether an active Dataverse environment connection exists before making a call, rather than letting the call fail first.
- **File system errors** need to account for missing files and invalid JSON when parsing file content.

## User feedback

Use four notification types, each with an appropriate persistence setting:

- **Success** — confirms an operation completed.
- **Info** — informational, non-blocking.
- **Warning** — something the user should be aware of but that didn't stop the operation.
- **Error** — the operation failed.

Match the persistence of the notification to its severity — errors typically need to stay visible longer than a transient success toast.

## Best practices

1. Always implement `try`/`catch` blocks for API calls.
2. Log errors with contextual information for debugging.
3. Provide actionable, specific messages to users.
4. Shield technical details from end users.
5. Clean up resources using `finally` blocks.
6. Validate input before making API calls.
7. Implement retry logic for transient failures.

## Common error reference

Map standard HTTP status codes to user-friendly messages so the same handling logic works across Dataverse and other HTTP-based APIs:

| Status code | Typical meaning |
| --- | --- |
| 400 | Bad request — invalid input |
| 401 | Not authenticated |
| 403 | Forbidden — insufficient privileges |
| 404 | Not found |
| 429 | Too many requests — throttled |
| 500 | Server error |
| 503 | Service unavailable |

Balance robustness with user experience: be transparent that something went wrong without exposing internal details the user can't act on.

## Checklist

- [ ] Every API call site is wrapped in `try`/`catch`.
- [ ] Errors are logged with enough context (operation, input, timestamp) to diagnose later.
- [ ] User-facing messages are specific and actionable, not raw error dumps.
- [ ] Cleanup logic runs in `finally` blocks regardless of success or failure.
- [ ] Input is validated before it reaches an API call.
- [ ] Transient failures (e.g., `429`, `503`) have retry logic.
- [ ] Notification type (success/info/warning/error) matches the severity of the event.

## Related links

- [Error Handling (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/error-handling)
- [Tool Development](/pptb-tools/tool-development/)
- [File System API](/pptb-tools/tool-development/file-system-api/)
