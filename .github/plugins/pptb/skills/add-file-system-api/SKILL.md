---
name: add-file-system-api
description: Wires up `toolboxAPI.fileSystem` calls — reading/writing text and binary files, checking existence, listing directories, and native save/select dialogs — into a PPTB tool's code. Use when asked to "read a config file in my tool", "let the user save/export a file", "let the user pick a file or folder", "list files in a directory", or "check if a file exists" from a PPTB tool.
---

# Add File System API

The File System API gives a PPTB tool secure, path-validated access to the local file system through `toolboxAPI.fileSystem` — reading configuration, exporting data, or letting a user pick a file/folder, without dropping to raw Node.js file APIs. This skill wires the right `toolboxAPI.fileSystem` calls in for the operation the tool needs.

**Key file operations live on `toolboxAPI.fileSystem`, not `toolboxAPI.utils` (where `saveFile`/`selectPath` used to live before the migration) — use absolute paths, check `exists()` before reading, and wrap every call in `try`/`catch` since all of them return Promises that can reject.**

## Step 1: Reading files

- `toolboxAPI.fileSystem.readText(path)` (v1.0.20) — reads a UTF-8 text file, returns `Promise<string>`.
- `toolboxAPI.fileSystem.readBinary(path)` (v1.0.20) — reads binary data, returns `Promise<Buffer>`.

Use `readText` for text content and `readBinary` for binary content — don't mix them (e.g. don't `readText` a zip file expecting to `JSON.parse` it directly, or `readBinary` a config file and manually decode UTF-8).

```typescript
const raw = await toolboxAPI.fileSystem.readText('/absolute/path/to/config.json')
const config = JSON.parse(raw)
```

## Step 2: File system queries

- `toolboxAPI.fileSystem.exists(path)` (v1.0.20) — `Promise<boolean>`. Check this **before** attempting to read a file that might not be present, rather than relying on the read call's rejection to signal "not found."
- `toolboxAPI.fileSystem.stat(path)` (v1.0.20) — metadata (type, size, modification time).
- `toolboxAPI.fileSystem.readDirectory(path)` (v1.0.20) — `Promise<DirectoryEntry[]>`, lists directory contents.

```typescript
if (!(await toolboxAPI.fileSystem.exists(path))) {
  return null
}
const raw = await toolboxAPI.fileSystem.readText(path)
```

## Step 3: Writing files

- `toolboxAPI.fileSystem.writeText(path, content)` (v1.0.20) — saves text content directly, no dialog, returns `Promise<void>`.
- `toolboxAPI.fileSystem.createDirectory(path)` (v1.0.20) — creates a directory recursively (missing parents included), returns `Promise<void>`.

Create the target directory before writing into it if it might not exist yet:

```typescript
await toolboxAPI.fileSystem.createDirectory('/absolute/path/to/output')
await toolboxAPI.fileSystem.writeText('/absolute/path/to/output/result.json', JSON.stringify(data))
```

## Step 4: User-interactive operations

- `toolboxAPI.fileSystem.saveFile(defaultPath, content, filters?)` (v1.0.20) — opens the native save dialog, returns `Promise<string | null>` (chosen path, or `null` if cancelled).
- `toolboxAPI.fileSystem.selectPath(options?)` (v1.0.20) — opens a native file/folder picker, returns `Promise<string | null>`.

Always handle the `null` return as "the user cancelled," not as an error:

```typescript
const chosenPath = await toolboxAPI.fileSystem.selectPath({ properties: ['openFile'] })
if (chosenPath === null) {
  return // user cancelled — not an error
}
```

## Step 5: Follow the API's own best practices

- Use absolute paths only — a relative path is a common source of "works on my machine" failures.
- Wrap every call in `try`/`catch` — missing file, permission denied, and invalid path are all real, expected failure modes here (see `add-error-handling`).
- `saveFile`/`selectPath` used to live under `toolboxAPI.utils` — if touching older code that still calls them there, migrate the call site to `toolboxAPI.fileSystem` while you're in the file.

## Checklist

- [ ] All File System API calls are wrapped in `try`/`catch`.
- [ ] Paths passed to the API are absolute, not relative.
- [ ] `exists()` is checked before reading a file that might not be present.
- [ ] Target directories are created with `createDirectory()` before writing files into them.
- [ ] Interactive dialogs (`saveFile`, `selectPath`) handle a `null` return when the user cancels, without treating it as an error.
- [ ] No remaining calls to `toolboxAPI.utils.saveFile()`/`selectPath()` — migrated to `toolboxAPI.fileSystem`.

## Next steps

- `add-error-handling` — the missing-file/invalid-JSON/permission-denied handling patterns this API needs
- `add-toolbox-api` — the rest of the platform-level API surface beyond file system access
- `add-dataverse-api` — `deploySolution()` reads a solution zip via `toolboxAPI.fileSystem.readBinary()` before deploying it
