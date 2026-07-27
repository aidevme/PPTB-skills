# Using the ToolBox API in a scaffolded tool

The starter `app.ts` from Step 5 only calls two `toolboxAPI` methods — `connections.getActiveConnection()` and `utils.showNotification()` — just enough to prove the tool loads and can see a connection. That's the floor, not the ceiling, of what `window.toolboxAPI` offers.

For the full surface — secondary connections, clipboard/theme/parallel-execution utils, opening a URL in the connection's browser, terminal sessions, inter-tool invocation, and tool context — hand off to the `add-toolbox-api` skill rather than re-deriving these calls from scratch. It covers:

- **Connections** — `getActiveConnection()` / `getSecondaryConnection()`, the full `Connection` type, and when to declare `features.multiConnection` in `package.json`.
- **Utils** — `showNotification`, `copyToClipboard`, `getCurrentTheme`, `executeParallel`, `openInConnectionBrowser`, and the removed `saveFile`/`selectPath` migration to the File System API.
- **Terminal** — `create` / `execute` / `setVisibility` / `list` / `close` session lifecycle.
- **Invocation** — direct `launchTool()` / `getLaunchContext()` / `returnData()` calls (for a discoverable capability contract instead, use `add-inter-tool-invocation`).
- **Tool context** — `getToolContext()` for the running tool's own IDs and connection URLs.

Reach for `add-toolbox-api` as soon as the scaffolded tool needs to do more than confirm it loaded — e.g. showing a notification tied to a real operation's success/failure, supporting a second connection, or launching another installed tool.
