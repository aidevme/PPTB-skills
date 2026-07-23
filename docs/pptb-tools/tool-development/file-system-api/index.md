---
title: File System API
description: The sandboxed file system access available to a PPTB tool, exposed through toolboxAPI.fileSystem.
source: https://docs.powerplatformtoolbox.com/tool-development/api-reference/filesystem-api
last_verified: 2026-07-22
---

# File System API

The File System API gives a PPTB tool secure, path-validated access to the local file system through `toolboxAPI.fileSystem`. Use it any time your tool needs to read configuration files, export data, or let a user pick a file or folder, without dropping down to raw Node.js file APIs.

**Key functions have migrated from `toolboxAPI.utils` to `toolboxAPI.fileSystem` — use `path`, check existence before reading, and wrap every call in `try`/`catch` since all operations return Promises that can reject.**

## Reading files

### `toolboxAPI.fileSystem.readText(path)`

Available since v1.0.20. Reads a UTF-8 text file and returns `Promise<string>`.

### `toolboxAPI.fileSystem.readBinary(path)`

Available since v1.0.20. Reads a file as binary data and returns `Promise<Buffer>`.

## File system queries

### `toolboxAPI.fileSystem.exists(path)`

Available since v1.0.20. Checks whether a file or directory exists and returns `Promise<boolean>`.

### `toolboxAPI.fileSystem.stat(path)`

Available since v1.0.20. Retrieves metadata for a file or directory, including type, size, and modification time.

### `toolboxAPI.fileSystem.readDirectory(path)`

Available since v1.0.20. Lists the contents of a directory and returns `Promise<DirectoryEntry[]>`.

## Writing files

### `toolboxAPI.fileSystem.writeText(path, content)`

Available since v1.0.20. Saves text content to disk without a save dialog. Returns `Promise<void>`.

### `toolboxAPI.fileSystem.createDirectory(path)`

Available since v1.0.20. Creates a directory recursively (creating any missing parent directories). Returns `Promise<void>`.

## User-interactive operations

### `toolboxAPI.fileSystem.saveFile(defaultPath, content, filters?)`

Available since v1.0.20. Opens the native save dialog so the user chooses where to save. Returns `Promise<string | null>` — the chosen path, or `null` if the user cancels.

### `toolboxAPI.fileSystem.selectPath(options?)`

Available since v1.0.20. Opens a native dialog for selecting a file or folder. Returns `Promise<string | null>`.

## Best practices

- Use absolute paths only.
- Check file existence with `exists()` before attempting to read.
- Wrap every File System API call in a `try`/`catch` block — these calls can fail (missing file, permission denied, invalid path).
- Create directories with `createDirectory()` before writing files into them.
- Use `readText` for text content and `readBinary` for binary content — don't mix them.

## Checklist

- [ ] All File System API calls are wrapped in `try`/`catch`.
- [ ] Paths passed to the API are absolute, not relative.
- [ ] `exists()` is checked before reading a file that might not be present.
- [ ] Target directories are created with `createDirectory()` before writing files into them.
- [ ] Interactive dialogs (`saveFile`, `selectPath`) handle a `null` return when the user cancels.

## Related links

- [File System API (upstream source)](https://docs.powerplatformtoolbox.com/tool-development/api-reference/filesystem-api)
- [Tool Development](/pptb-tools/tool-development/)
- [Error Handling](/pptb-tools/tool-development/error-handling/)
