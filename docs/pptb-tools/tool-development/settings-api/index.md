---
title: Settings API
description: How a PPTB tool reads and persists its own configuration.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/settings-api
last_verified: 2026-07-22
---

# Settings API

The Settings API lets a tool persist user preferences across sessions — things like page size, theme, and grid configuration — keyed per tool. This page covers the four core methods, the best practices the documentation recommends, and worked examples for common preference-storage scenarios.

**Use `get`/`set`/`getAll`/`setAll` for user preferences only — never for transient application state (current page number, selected rows) — and always namespace keys (`ui.pageSize`, not `pageSize`) and supply a default when reading, since a setting may not exist yet.**

## Reading settings

### `toolboxAPI.settings.getAll()`

Requires v1.0.17

Retrieves all settings for your tool.

**Returns:** `Promise<Record<string, any>>` — object containing all settings key-value pairs

```javascript
const settings = await toolboxAPI.settings.getAll()
console.log('All settings:', JSON.stringify(settings))

// Example output:
// {
//   "pageSize": 50,
//   "defaultColor": "blue",
//   "showAdvancedOptions": true,
//   "lastUsedFilter": "active"
// }
```

### `toolboxAPI.settings.get(key)`

Requires v1.0.17

Retrieves a specific setting by key.

**Parameters:** `key: string` — the setting key to retrieve
**Returns:** `Promise<any>` — value of the setting, or `undefined` if not found

```javascript
const pageSize = await toolboxAPI.settings.get('pageSize')
console.log('Page Size setting:', pageSize) // Output: 50

// Handle missing settings with defaults
const pageSize2 = (await toolboxAPI.settings.get('pageSize')) || 25
const theme = (await toolboxAPI.settings.get('theme')) || 'light'
```

## Writing settings

### `toolboxAPI.settings.set(key, value)`

Requires v1.0.17

Sets a specific setting by key. `value` is serialized to JSON.

**Parameters:** `key: string`, `value: any`
**Returns:** `Promise<void>`

```javascript
await toolboxAPI.settings.set('pageSize', 50)
await toolboxAPI.settings.set('defaultColor', 'blue')
await toolboxAPI.settings.set('showAdvancedOptions', true)

// Store complex objects
await toolboxAPI.settings.set('lastFilter', {
  type: 'status',
  value: 'active',
  appliedAt: new Date().toISOString(),
})
```

### `toolboxAPI.settings.setAll(settings)`

Requires v1.0.17

Sets multiple settings at once — use this for batch updates instead of several sequential `set()` calls.

**Parameters:** `settings: Record<string, any>`
**Returns:** `Promise<void>`

```javascript
await toolboxAPI.settings.setAll({
  defaultColor: 'blue',
  pageSize: 50,
  showAdvancedOptions: true,
  lastUsedFilter: 'active',
})
```

## Best practices

### Use meaningful keys

Use descriptive, namespaced keys to avoid conflicts:

```javascript
// Good: Descriptive keys
await toolboxAPI.settings.set('ui.pageSize', 50)
await toolboxAPI.settings.set('ui.theme', 'dark')
await toolboxAPI.settings.set('data.cacheExpiry', 3600)

// Bad: Vague keys
await toolboxAPI.settings.set('size', 50)
await toolboxAPI.settings.set('value', 'dark')
```

### Provide default values

Always provide fallback values when reading settings:

```javascript
// Good: Default values
const pageSize = (await toolboxAPI.settings.get('pageSize')) || 25
const theme = (await toolboxAPI.settings.get('theme')) || 'light'

// Even better: Use a defaults object
const DEFAULTS = {
  pageSize: 25,
  theme: 'light',
  showWelcome: true,
}

async function getSetting(key) {
  const value = await toolboxAPI.settings.get(key)
  return value !== undefined ? value : DEFAULTS[key]
}
```

### Validate settings

Validate settings before using them:

```javascript
async function getPageSize() {
  const pageSize = await toolboxAPI.settings.get('pageSize')

  if (typeof pageSize === 'number' && pageSize > 0 && pageSize <= 100) {
    return pageSize
  }

  return 25
}
```

### Batch updates

When updating multiple settings, use `setAll()` for better performance:

```javascript
// Good: Batch update
await toolboxAPI.settings.setAll({
  pageSize: 50,
  sortColumn: 'name',
  sortDirection: 'asc',
  filters: { status: 'active' },
})

// Bad: Multiple individual updates
await toolboxAPI.settings.set('pageSize', 50)
await toolboxAPI.settings.set('sortColumn', 'name')
await toolboxAPI.settings.set('sortDirection', 'asc')
await toolboxAPI.settings.set('filters', { status: 'active' })
```

### Store only user preferences

Store only user preferences, not application state or temporary data:

```javascript
// Good: User preferences
await toolboxAPI.settings.set('defaultView', 'grid')
await toolboxAPI.settings.set('itemsPerPage', 50)

// Bad: Temporary/application state (use local state instead)
await toolboxAPI.settings.set('currentPageNumber', 3)
await toolboxAPI.settings.set('selectedItems', [1, 2, 3])
```

### Handle errors

Always handle potential errors when working with settings:

```javascript
try {
  await toolboxAPI.settings.set('pageSize', 50)
} catch (error) {
  console.error('Failed to save setting:', error)
  await toolboxAPI.utils.showNotification({
    title: 'Error',
    body: 'Failed to save preferences',
    type: 'error',
  })
}
```

## Examples

### Save and load form preferences

```javascript
// Save form state
async function saveFormPreferences(formData) {
  await toolboxAPI.settings.setAll({
    'form.defaultEnvironment': formData.environment,
    'form.showAdvanced': formData.showAdvanced,
    'form.autoRefresh': formData.autoRefresh,
  })
}

// Load form state
async function loadFormPreferences() {
  const settings = await toolboxAPI.settings.getAll()

  return {
    environment: settings['form.defaultEnvironment'] || 'production',
    showAdvanced: settings['form.showAdvanced'] || false,
    autoRefresh: settings['form.autoRefresh'] || true,
  }
}
```

### Theme preference

```javascript
// Apply and save theme preference
async function setTheme(theme) {
  document.body.classList.remove('theme-light', 'theme-dark')
  document.body.classList.add(`theme-${theme}`)

  await toolboxAPI.settings.set('ui.theme', theme)
}

// Load theme on startup
async function loadTheme() {
  const theme = (await toolboxAPI.settings.get('ui.theme')) || 'light'
  document.body.classList.add(`theme-${theme}`)
}
```

### Data grid preferences

```javascript
// Save grid configuration
async function saveGridConfig(config) {
  await toolboxAPI.settings.setAll({
    'grid.pageSize': config.pageSize,
    'grid.sortColumn': config.sortColumn,
    'grid.sortDirection': config.sortDirection,
    'grid.visibleColumns': config.visibleColumns,
    'grid.density': config.density,
  })
}

// Load grid configuration
async function loadGridConfig() {
  const settings = await toolboxAPI.settings.getAll()

  return {
    pageSize: settings['grid.pageSize'] || 25,
    sortColumn: settings['grid.sortColumn'] || 'name',
    sortDirection: settings['grid.sortDirection'] || 'asc',
    visibleColumns: settings['grid.visibleColumns'] || ['name', 'status', 'date'],
    density: settings['grid.density'] || 'comfortable',
  }
}
```

## Checklist

- [ ] Setting keys are namespaced (`ui.pageSize`, `grid.sortColumn`) rather than generic (`size`, `value`).
- [ ] Every `get()` call has a fallback default for the case where the setting hasn't been set yet.
- [ ] Values are validated (type and range) before use, not trusted blindly.
- [ ] Multiple related settings are written with `setAll()` instead of sequential `set()` calls.
- [ ] Only durable user preferences are stored — transient UI state (current page, selection) stays in local component state.
- [ ] `settings.set()`/`setAll()` calls are wrapped in try/catch with user-facing error feedback.
- [ ] Your tool listens for the `settings:updated` event (see [Events API](/pptb-tools/tool-development/events-api/)) if it needs to react to settings changed elsewhere.

## Related links

- [Settings API (source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/settings-api)
- [Overview](/pptb-tools/tool-development/)
- [API Reference](/pptb-tools/tool-development/api-reference/)
- [Events API](/pptb-tools/tool-development/events-api/)
- [ToolBox API](/pptb-tools/tool-development/toolbox-api/)
