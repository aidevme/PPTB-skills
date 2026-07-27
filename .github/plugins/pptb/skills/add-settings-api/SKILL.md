---
name: add-settings-api
description: Wires up `toolboxAPI.settings` calls (`get`/`set`/`getAll`/`setAll`) so a PPTB tool persists user preferences across sessions — page size, theme, grid configuration. Use when asked to "save this preference for my tool", "persist the user's theme/page size/grid settings", "load saved settings on startup", or "store this configuration across sessions" for a PPTB tool.
---

# Add Settings API

The Settings API lets a PPTB tool persist user preferences across sessions, keyed per tool. This skill wires up `toolboxAPI.settings` calls for reading and writing those preferences.

**Use `get`/`set`/`getAll`/`setAll` for durable user preferences only — never for transient application state (current page number, selected rows, in-progress form state) — and always namespace keys (`ui.pageSize`, not `pageSize`) with a default supplied when reading, since a setting may not exist yet.**

## Step 1: Read settings with a default

```typescript
const pageSize = (await toolboxAPI.settings.get('ui.pageSize')) ?? 25
const theme = (await toolboxAPI.settings.get('ui.theme')) ?? 'light'
```

`get(key)` (v1.0.17) returns `Promise<any>` — `undefined` if the key was never set, so always supply a fallback rather than assuming a value exists. For a set of related preferences, prefer `getAll()` (v1.0.17, `Promise<Record<string, any>>`) over multiple `get()` calls, paired with a defaults object:

```typescript
const DEFAULTS = { pageSize: 25, theme: 'light', showWelcome: true }

async function getSetting<K extends keyof typeof DEFAULTS>(key: K) {
  const settings = await toolboxAPI.settings.getAll()
  return settings[key] !== undefined ? settings[key] : DEFAULTS[key]
}
```

## Step 2: Write settings with namespaced keys

`set(key, value)` (v1.0.17) serializes `value` to JSON and returns `Promise<void>`. Namespace every key so unrelated preferences don't collide:

```typescript
// Bad — vague, collision-prone
await toolboxAPI.settings.set('size', 50)

// Good — namespaced
await toolboxAPI.settings.set('ui.pageSize', 50)
await toolboxAPI.settings.set('grid.sortColumn', 'name')
```

For multiple related settings, use `setAll(settings)` (v1.0.17, `Promise<void>`) instead of sequential `set()` calls — one batched write instead of several round trips:

```typescript
await toolboxAPI.settings.setAll({
  'grid.pageSize': 50,
  'grid.sortColumn': 'name',
  'grid.sortDirection': 'asc',
})
```

## Step 3: Validate before use

Don't trust a stored setting's type or range blindly — a value written by an older version of the tool, or edited manually in the settings file, can be malformed:

```typescript
async function getPageSize() {
  const pageSize = await toolboxAPI.settings.get('ui.pageSize')
  if (typeof pageSize === 'number' && pageSize > 0 && pageSize <= 100) {
    return pageSize
  }
  return 25
}
```

## Step 4: Store only durable preferences

Settings are for things that should survive across sessions — view mode, theme, page size, grid configuration. They are not for transient UI state:

```typescript
// Good — durable preference
await toolboxAPI.settings.set('defaultView', 'grid')

// Bad — transient state; keep this in local component state instead
await toolboxAPI.settings.set('currentPageNumber', 3)
await toolboxAPI.settings.set('selectedItems', [1, 2, 3])
```

## Step 5: Wrap writes in try/catch with user feedback

```typescript
try {
  await toolboxAPI.settings.set('ui.pageSize', 50)
} catch (error) {
  console.error('Failed to save setting:', error)
  await toolboxAPI.utils.showNotification({
    title: 'Error',
    body: 'Failed to save preferences',
    type: 'error',
  })
}
```

## Step 6: React to settings changed elsewhere

If the tool needs to pick up a settings change made outside its own code path (another tool instance, a future settings UI), listen for the `settings:updated` event — see `add-events-api` — rather than re-polling `getAll()`.

## Checklist

- [ ] Setting keys are namespaced (`ui.pageSize`, `grid.sortColumn`) rather than generic (`size`, `value`).
- [ ] Every `get()` call has a fallback default for the case where the setting hasn't been set yet.
- [ ] Values are validated (type and range) before use, not trusted blindly.
- [ ] Multiple related settings are written with `setAll()` instead of sequential `set()` calls.
- [ ] Only durable user preferences are stored — transient UI state (current page, selection) stays in local component state.
- [ ] `settings.set()`/`setAll()` calls are wrapped in try/catch with user-facing error feedback.
- [ ] The tool listens for the `settings:updated` event if it needs to react to settings changed elsewhere.

## Next steps

- `add-events-api` — the `settings:updated` event this API pairs with for reacting to external changes
- `add-error-handling` — the try/catch + user-facing notification pattern applied in Step 5
