---
title: Events API
description: How a PPTB tool subscribes to and emits events within the toolbox.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/events
last_verified: 2026-07-22
---

# Events API

The Events API lets a tool subscribe to platform events — connection changes, settings updates, notifications, terminal activity, and tool lifecycle transitions — so it can react without polling. This page covers the subscription method, the full list of event types, and the registration patterns the documentation recommends.

**Subscribe with `toolboxAPI.events.on(handler)` once during initialization, route on `payload.event` inside a single handler, and wrap the handler body in try/catch — registering multiple handlers or letting one throw can silently break event delivery for the rest of your tool.**

## Event subscription

### `toolboxAPI.events.on(handler)`

Requires v1.0.17

Subscribe to events relevant to your tool.

**Parameters:**

- `handler: (event: any, payload: ToolBoxEventPayload) => void` — callback function to handle events

```javascript
toolboxAPI.events.on((details, payload) => {
  switch (payload.event) {
    case 'connection:updated':
      refreshConnectionInfo()
      break
    case 'terminal:command:completed':
      handleCommandCompleted(payload.data)
      break
    case 'settings:updated':
      if (payload.data && payload.data.theme) {
        applyTheme(payload.data.theme)
      }
      break
  }
})
```

**`ToolBoxEventPayload`:**

```typescript
interface ToolBoxEventPayload {
  event: ToolBoxEvent
  data: unknown
  timestamp: string
}
```

## Event types

### `tool:loaded` / `tool:unloaded`

Requires v1.0.17

Fired when a tool instance is loaded or unloaded.

```javascript
toolboxAPI.events.on((_, payload) => {
  if (payload.event === 'tool:loaded') {
    initializeTool()
  }

  if (payload.event === 'tool:unloaded') {
    cleanupResources()
  }
})
```

### `connection:created` / `connection:updated` / `connection:deleted`

Requires v1.0.17

Fired when Dataverse connections are created, updated, or deleted.

```javascript
toolboxAPI.events.on((_, payload) => {
  if (payload.event === 'connection:updated') {
    console.log('Connection event:', payload.data)
    refreshConnectionInfo()
  }
})
```

### `settings:updated`

Requires v1.0.17

Fired when tool settings are changed.

```javascript
toolboxAPI.events.on((_, payload) => {
  if (payload.event === 'settings:updated') {
    console.log('Settings updated:', payload.data)
  }
})
```

### `notification:shown`

Requires v1.0.17

Fired when a notification is displayed.

```javascript
toolboxAPI.events.on((_, payload) => {
  if (payload.event === 'notification:shown') {
    console.log('Notification shown:', payload.data)
  }
})
```

### `terminal:created` / `terminal:closed` / `terminal:output` / `terminal:command:completed` / `terminal:error`

Requires v1.0.17

Fired for terminal lifecycle, output streaming, command completion, and terminal errors.

```javascript
toolboxAPI.events.on((_, payload) => {
  switch (payload.event) {
    case 'terminal:created':
      console.log('Terminal created:', payload.data)
      break
    case 'terminal:output':
      console.log('Terminal output:', payload.data)
      break
    case 'terminal:command:completed':
      console.log('Command completed:', payload.data)
      break
    case 'terminal:error':
      console.error('Terminal error:', payload.data)
      break
  }
})
```

## Best practices

> **Important:** Subscribe to events early in your tool's initialization to avoid missing important events.

### Register once

Register your event handler only once during initialization:

```javascript
// Good: Register once during initialization
function initializeTool() {
  toolboxAPI.events.on(handleEvent)
}

function handleEvent(event, payload) {
  // Handle all events in one place
}

initializeTool()
```

### Avoid multiple handlers

Don't register multiple event handlers for the same events:

```javascript
// Bad: Multiple handlers
toolboxAPI.events.on(handler1)
toolboxAPI.events.on(handler2)

// Good: Single handler with routing
toolboxAPI.events.on((event, payload) => {
  switch (event) {
    case 'connection:updated':
      handleConnectionUpdate(payload)
      break
    case 'settings:updated':
      handleSettingsUpdate(payload)
      break
  }
})
```

### Error handling

Always wrap event handler logic in try/catch blocks:

```javascript
toolboxAPI.events.on((event, payload) => {
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
- [ ] `settings:updated`, `connection:updated`, and any terminal events your tool depends on are all covered by the routing logic.

## Related links

- [Events API (source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/events)
- [Overview](/pptb-tools/tool-development/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
- [ToolBox API](/pptb-tools/tool-development/toolbox-api/)
- [Settings API](/pptb-tools/tool-development/settings-api/)
