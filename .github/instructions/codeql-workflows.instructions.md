---
applyTo: "**/*codeql*.yml"
---

# CodeQL workflow implementation instructions

Use these rules when creating or modifying CodeQL workflow templates and active workflows.

## Choose the setup model

- Prefer CodeQL default setup when the repository language or build system is unknown.
- Use an advanced workflow only when the repository needs explicit control over languages, build modes, runners, queries, paths, or schedules.
- Do not configure default setup and an advanced CodeQL workflow for the same repository.
- Reuse the closest single-language starter under `templates/workflows/codeql/` instead of generating a workflow from memory.

## Select the language and build mode

Use only supported CodeQL language identifiers:

| Project language | CodeQL identifier | Generic build mode |
| --- | --- | --- |
| GitHub Actions | `actions` | Omit `build-mode` |
| C or C++ | `c-cpp` | `none` |
| C# | `csharp` | `none` |
| Go | `go` | `autobuild` |
| Java | `java-kotlin` | `none` |
| Kotlin or Java and Kotlin | `java-kotlin` | `autobuild` |
| JavaScript or TypeScript | `javascript-typescript` | Omit `build-mode` |
| Python | `python` | Omit `build-mode` |
| Ruby | `ruby` | Omit `build-mode` |
| Rust | `rust` | `none` |
| Swift | `swift` | `autobuild` |

- Treat `actions` support as public preview until GitHub announces general availability.
- Do not use `build-mode: none` for Kotlin, Go, or Swift.
- Remember that `java-kotlin` with `build-mode: none` analyzes Java but not Kotlin.
- Use `macos-latest` for Swift. Use `ubuntu-latest` unless the project requires another operating system.
- Change `autobuild` to `manual` only when automatic detection is insufficient. Add real build commands between the CodeQL initialization and analysis steps; never leave placeholder build commands in an active workflow.

## Define workflow behavior

- Analyze pushes and pull requests targeting the default branch.
- Include `workflow_dispatch` for manual verification.
- Include a weekly scheduled scan unless organization policy supplies another schedule.
- Set `permissions: contents: read` at workflow level.
- Grant the analysis job only `actions: read`, `contents: read`, `packages: read`, and `security-events: write`.
- Use one analysis category per language, formatted as `/language:<codeql-identifier>`.
- For multi-language repositories, use a reviewed matrix with one language and build mode per entry. Do not copy several independent single-language workflows into the same repository.

## Pin actions securely

- Pin `actions/checkout` and every `github/codeql-action` step to full commit SHAs.
- Add the exact release tag as an inline comment after each SHA.
- Use the same verified CodeQL release for `init`, `autobuild` when present, and `analyze`.
- Verify new action versions support Node 24 before updating pins.
- Follow `.github/instructions/github-actions-node-version.instructions.md` for all action-version changes.

## Validate the implementation

- Confirm the configured language exists in the repository before enabling an advanced workflow.
- Validate the YAML syntax and ensure GitHub expressions remain intact.
- Verify every pinned SHA resolves to the release named in its comment.
- Confirm the selected build mode is supported for the language.
- For compiled projects, review the first database build for missing generated code, dependencies, or compilation units.
- If CodeQL reports that no source code was seen, correct the language or build configuration instead of suppressing the failure.
- Review the first successful result under **Security** > **Code scanning**.

## Maintain reusable templates

- Keep files under `templates/workflows/codeql/` inactive; users copy one into `.github/workflows/codeql.yml`.
- Preserve one project language or shared CodeQL identifier per template.
- Update `templates/workflows/codeql/README.md` whenever templates, supported languages, build modes, or required customization steps change.
- Reverify official GitHub documentation before changing supported languages or build-mode guidance.
