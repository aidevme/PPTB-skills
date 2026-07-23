---
applyTo: ".github/workflows/*.yml"
---

# GitHub Actions runner Node version instructions

GitHub Actions runners now default to **Node 24** (effective June 16, 2026). Node 20 will be fully removed in fall 2026.

## Rules for workflow files

- All `actions/setup-node` steps must set `node-version: 24` or higher. Do not use `20`.
- When pinning third-party actions by SHA, add a comment with the exact version tag (e.g., `# v24.1.0`).
- Before adding or updating a pinned action, verify the version runs on Node 24 by checking its release notes.
- Node 24 is incompatible with macOS 13.4 and lower and does not support ARM32 self-hosted runners.

## Checking action Node compatibility

An action runs on Node 24 if:

- Its `action.yml` declares `using: node24`, or
- Its release notes explicitly state the Node runtime was updated to 24.

For `DavidAnson/markdownlint-cli2-action`, Node 24 support was added in **v23.0.0**.

## Updating an action to a newer version

1. Check the action's releases page for the latest version and its commit SHA.
2. Replace both the SHA and the version comment in the workflow:

   ```yaml
   # Before
   uses: owner/action@<old-sha> # v1.0.0

   # After
   uses: owner/action@<new-sha> # v1.1.0
   ```

3. Run `scripts/sync-cspell.ps1` if the release notes introduce new proper names flagged by spell check.

## Current pinned versions (validate-markdown.yml)

| Action | Pinned SHA | Version |
| --- | --- | --- |
| `actions/checkout` | `9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0` | v7 |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | v7 |
| `DavidAnson/markdownlint-cli2-action` | `6bf21b07787794f89a243495939cd651942aeabe` | v24.1.0 |
| `tcort/github-action-markdown-link-check` | `e7c7a18363c842693fadde5d41a3bd3573a7a225` | v1.1.2 |

## Current pinned versions (deploy-vitepress.yml)

| Action | Pinned SHA | Version |
| --- | --- | --- |
| `actions/checkout` | `9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0` | v7 |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | v7 |
| `actions/cache` | `55cc8345863c7cc4c66a329aec7e433d2d1c52a9` | v6 |
| `actions/configure-pages` | `45bfe0192ca1faeb007ade9deae92b16b8254a0d` | v6 |
| `actions/upload-pages-artifact` | `fc324d3547104276b827a68afc52ff2a11cc49c9` | v5 |
| `actions/deploy-pages` | `cd2ce8fcbc39b97be8ca5fce6e763baed58fa128` | v5 |
