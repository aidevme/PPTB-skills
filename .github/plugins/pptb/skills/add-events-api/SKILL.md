---
name: add-events-api
description: Wires up `toolboxAPI.events.on()` so a PPTB tool reacts to platform events — connection changes, settings updates, notifications, terminal activity, tool lifecycle — instead of polling. Use when asked to "react when the connection changes", "listen for settings updates", "run something when a terminal command finishes", "subscribe to tool lifecycle events", or "my tool needs to know when X happens without polling".
---

# Add Events API

The Events API lets a PPTB tool subscribe to platform events — connection changes, settings updates, notifications, terminal activity, and tool lifecycle transitions — so it can react without polling. This skill wires up a single `toolboxAPI.events.on()` subscription and routes it across whichever event types the tool needs.

**Subscribe with `toolboxAPI.events.on(handler)` exactly once during initialization, route on `payload.event` inside that single handler, and wrap the handler body in try/catch — registering multiple handlers or letting one throw can silently break event delivery for the rest of the tool.**

## Step 1: Subscribe once, early

Register the handler during initialization, before anything that depends on receiving events — subscribing late risks missing events fired between tool load and subscription:

```typescript
function initializeTool() {
  toolboxAPI.events.on(handleEvent)
}

function handleEvent(_details: unknown, payload: ToolBoxEventPayload) {
  // route on payload.event below
}

initializeTool()
```

Never register a second handler for the same purpose — route everything through one `switch`/`if` chain instead:

```typescript
// Bad
toolboxAPI.events.on(handler1)
toolboxAPI.events.on(handler2)

// Good — single handler, routes internally
toolboxAPI.events.on((_details, payload) => {
  switch (payload.event) {
    case 'connection:updated':
      handleConnectionUpdate(payload)
      break
    case 'settings:updated':
      handleSettingsUpdate(payload)
      break
  }
})
```

## Step 2: Route on the event types the tool actually needs

`payload: ToolBoxEventPayload` is `{ event: ToolBoxEvent, data: unknown, timestamp: string }`. The event catalog:

| Event | Fires when |
| --- | --- |
| `tool:loaded` / `tool:unloaded` | This tool instance is loaded/unloaded |
| `connection:created` / `connection:updated` / `connection:deleted` | A Dataverse connection changes |
| `settings:updated` | Tool settings change (see `add-settings-api`) |
| `notification:shown` | A notification is displayed |
| `terminal:created` / `terminal:closed` / `terminal:output` / `terminal:command:completed` / `terminal:error` | Terminal lifecycle, output, completion, or error |

```typescript
toolboxAPI.events.on((_details, payload) => {
  switch (payload.event) {
    case 'connection:updated':
      refreshConnectionInfo()
      break
    case 'terminal:command:completed':
      handleCommandCompleted(payload.data)
      break
    case 'settings:updated':
      if (payload.data && (payload.data as any).theme) {
        applyTheme((payload.data as any).theme)
      }
      break
  }
})
```

Only add cases for events the tool actually reacts to — an empty `case` that does nothing is dead code, not defensive coverage.

## Step 3: Wrap the handler body in try/catch

One event's handling error must not break delivery of the next event:

```typescript
toolboxAPI.events.on((_details, payload) => {
  try {
    switch (payload.event) {
      case 'connection:updated':
        refreshData()
        break
      case 'settings:updated':
        applySettings(payload.data)
        break
    }
  } catch (error) {
    console.error('Error handling event:', payload.event, error)
  }
})
```

## Checklist

- [ ] `toolboxAPI.events.on()` is called exactly once, early in tool initialization.
- [ ] The handler routes on `payload.event` with a single `switch`/`if` chain rather than registering separate handlers per event.
- [ ] Handler logic is wrapped in try/catch so one event's error doesn't break handling of subsequent events.
- [ ] `settings:updated`, `connection:updated`, and any terminal events the tool depends on are all covered by the routing logic.

## Next steps

- `add-settings-api` — `settings:updated` fires whenever this tool's own settings change elsewhere; the two skills are usually wired together
- `add-toolbox-api` — `connection:updated` pairs with `getActiveConnection()`/`getSecondaryConnection()` to refresh connection state
- `add-error-handling` — the try/catch pattern here is the same one applied to every other API call site
