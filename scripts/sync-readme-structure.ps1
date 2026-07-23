#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Syncs the auto-generated repository structure tree in README.md with the
    current contents of the repo.

.DESCRIPTION
    Scans git-tracked files (via `git ls-files`, so gitignored build output is
    automatically skipped) and renders a directory tree — directories first,
    then files, alphabetical within each level. A small set of per-path
    descriptive comments (see $annotations below) is appended next to matching
    entries, mirroring how the tree previously looked when hand-written.

    The generated tree replaces the content between the
        <!-- BEGIN AUTO-GENERATED: repo-structure -->
        <!-- END AUTO-GENERATED: repo-structure -->
    markers in README.md, leaving the rest of the file untouched.

.PARAMETER Check
    Do not modify README.md. Exit with code 1 if the generated tree would
    differ from what is currently in the file. Useful in CI to catch a repo
    structure that has drifted out of sync with README.md.

.PARAMETER WhatIf
    Show the lines that would be added/removed without writing to disk.

.EXAMPLE
    ./scripts/sync-readme-structure.ps1
    ./scripts/sync-readme-structure.ps1 -Check
    ./scripts/sync-readme-structure.ps1 -WhatIf
#>
param(
    [switch]$Check,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot   = Resolve-Path (Join-Path $PSScriptRoot '..')
$readmePath = Join-Path $repoRoot 'README.md'
$repoName   = Split-Path -Leaf $repoRoot
$beginMarker = '<!-- BEGIN AUTO-GENERATED: repo-structure -->'
$endMarker   = '<!-- END AUTO-GENERATED: repo-structure -->'

if (-not (Test-Path $readmePath)) {
    throw "README.md not found at $readmePath"
}

# Optional per-path descriptive comments shown next to matching tree entries.
# Keyed by repo-relative path with forward slashes, no trailing slash on dirs.
$annotations = @{
    'docs'                                                                     = 'Chapter and workflow drafts'
    'docs/packt-publishing/copilot-cowork-playbook/copilot-cowork-playbook.md' = 'Main manuscript'
    'templates'                                                                = 'Packt-supplied Word and nanobook templates'
    'assets'                                                                   = 'Images, cover art, reference materials'
    'scripts/convert-docs-to-html.ps1'                                         = 'Renders docs/*.md to standalone HTML'
    'scripts/sync-code-owners.ps1'                                             = 'Syncs the docs/ block of .github/CODEOWNERS'
    'scripts/sync-cspell.ps1'                                                  = 'Syncs cspell.json with unknown words found in Markdown'
    'scripts/sync-readme-structure.ps1'                                        = 'Syncs this repository structure tree'
    'scripts/validate-markdown.ps1'                                            = 'Lints Markdown files'
    'docs/repository/scripts'                                                  = 'Documentation for each PowerShell script'
    '.github/copilot-instructions.md'                                          = 'Project conventions for AI-assisted editing'
    '.github/instructions/commit-messages.instructions.md'                     = 'Conventional Commits format'
    'WRITING_STYLE_GENERAL.md'                                                 = 'Style guide for playbook-format content'
    'WRITING_STYLE_PACKT_NANOBOOK.md'                                          = 'Style guide for chapter-based content'
    'LICENSE'                                                                  = 'MIT license'
}

# ---------------------------------------------------------------------------
# 1. Discover git-tracked files and build a nested tree of directories/files
# ---------------------------------------------------------------------------
Push-Location $repoRoot
try {
    $trackedFiles = @(& git ls-files)
    if ($LASTEXITCODE -ne 0) {
        throw "git ls-files failed."
    }
} finally {
    Pop-Location
}

$trackedFiles = @($trackedFiles | Where-Object { $_ } | ForEach-Object { $_ -replace '\\', '/' })

if ($trackedFiles.Count -eq 0) {
    throw "No git-tracked files found. Refusing to generate an empty repository structure tree."
}

function New-TreeNode {
    [ordered]@{ Children = [ordered]@{}; IsFile = $false }
}

$root = New-TreeNode
foreach ($file in $trackedFiles) {
    $parts = $file.Split('/')
    $node = $root
    for ($i = 0; $i -lt $parts.Count; $i++) {
        $part = $parts[$i]
        if (-not $node.Children.Contains($part)) {
            $node.Children[$part] = New-TreeNode
        }
        $node = $node.Children[$part]
        if ($i -eq $parts.Count - 1) {
            $node.IsFile = $true
        }
    }
}

# ---------------------------------------------------------------------------
# 2. Render the tree: directories first, then files, alphabetical within each
# ---------------------------------------------------------------------------
function Get-SortedNames {
    param($Node)
    $dirNames  = @($Node.Children.Keys | Where-Object { -not $Node.Children[$_].IsFile } | Sort-Object -CaseSensitive:$false)
    $fileNames = @($Node.Children.Keys | Where-Object { $Node.Children[$_].IsFile } | Sort-Object -CaseSensitive:$false)
    ,($dirNames + $fileNames)
}

$treeLines = [System.Collections.Generic.List[string]]::new()

function Write-TreeLines {
    param($Node, [string]$Prefix, [string]$PathPrefix)

    $names = Get-SortedNames -Node $Node
    for ($i = 0; $i -lt $names.Count; $i++) {
        $name = $names[$i]
        $child = $Node.Children[$name]
        $isLast = ($i -eq $names.Count - 1)
        $connector = if ($isLast) { [char]0x2514 + [char]0x2500 + [char]0x2500 + ' ' } else { [char]0x251C + [char]0x2500 + [char]0x2500 + ' ' }
        $childPath = if ($PathPrefix) { "$PathPrefix/$name" } else { $name }
        $label = if ($child.IsFile) { $name } else { "$name/" }

        $comment = if ($annotations.Contains($childPath)) { "  # $($annotations[$childPath])" } else { '' }
        $treeLines.Add("$Prefix$connector$label$comment")

        if (-not $child.IsFile) {
            $extension = if ($isLast) { '    ' } else { [char]0x2502 + '   ' }
            Write-TreeLines -Node $child -Prefix "$Prefix$extension" -PathPrefix $childPath
        }
    }
}

$treeLines.Add("$repoName/")
Write-TreeLines -Node $root -Prefix '' -PathPrefix ''

# ---------------------------------------------------------------------------
# 3. Format the generated block
# ---------------------------------------------------------------------------
$generatedLines = [System.Collections.Generic.List[string]]::new()
$generatedLines.Add($beginMarker)
$generatedLines.Add('```text')
foreach ($line in $treeLines) { $generatedLines.Add($line) }
$generatedLines.Add('```')
$generatedLines.Add($endMarker)

# ---------------------------------------------------------------------------
# 4. Splice the generated block into README.md between the markers
# ---------------------------------------------------------------------------
$originalLines = @([System.IO.File]::ReadAllLines($readmePath, [System.Text.Encoding]::UTF8))

$beginIndex = [array]::IndexOf($originalLines, $beginMarker)
$endIndex   = [array]::IndexOf($originalLines, $endMarker)

if ($beginIndex -lt 0 -or $endIndex -lt 0 -or $endIndex -lt $beginIndex) {
    throw "Could not find '$beginMarker' / '$endMarker' markers in $readmePath. Add them around the repository structure fenced code block before running this script."
}

$existingBlock = @($originalLines[$beginIndex..$endIndex])

if (-not (Compare-Object $existingBlock $generatedLines -SyncWindow 0)) {
    Write-Host "README.md repository structure is already up to date." -ForegroundColor Green
    exit 0
}

if ($Check) {
    Write-Host "README.md repository structure is out of date. Run scripts/sync-readme-structure.ps1 to fix." -ForegroundColor Red
    Write-Host "`nExpected:" -ForegroundColor Yellow
    $generatedLines | ForEach-Object { Write-Host "  $_" }
    exit 1
}

if ($WhatIf) {
    Write-Host "README.md repository structure would change:" -ForegroundColor Yellow
    Compare-Object $existingBlock $generatedLines -SyncWindow 0 |
        ForEach-Object {
            $prefix = if ($_.SideIndicator -eq '=>') { '+' } else { '-' }
            $color  = if ($_.SideIndicator -eq '=>') { 'Green' } else { 'Red' }
            Write-Host "  $prefix $($_.InputObject)" -ForegroundColor $color
        }
    exit 0
}

$newLines = @()
if ($beginIndex -gt 0) { $newLines += $originalLines[0..($beginIndex - 1)] }
$newLines += $generatedLines
if ($endIndex -lt $originalLines.Count - 1) { $newLines += $originalLines[($endIndex + 1)..($originalLines.Count - 1)] }

$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($readmePath, ($newLines -join "`n") + "`n", $utf8WithoutBom)

Write-Host "Updated README.md repository structure with $($treeLines.Count) entries." -ForegroundColor Green
