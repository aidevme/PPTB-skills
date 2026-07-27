#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Checks that every SKILL.md in the PPTB skills plugin stays under the
    recommended line limit.

.DESCRIPTION
    Scans .github/plugins/pptb/skills/*/SKILL.md, counts lines in each, and
    reports any file at or over the limit (500 lines by default - see the
    "Progressive disclosure" section of
    docs/miscellaneous/agent-skills/specification/index.md, and the
    "SKILL.md is still under 500 lines" checklist item in the skill-update
    PR template). Empty stub files (not-yet-drafted skills) are skipped,
    since a 0-line file trivially satisfies the limit and isn't a
    formatting problem to report.

.PARAMETER SkillsPath
    Path to the skills directory to scan, relative to the repo root.
    Defaults to .github/plugins/pptb/skills.

.PARAMETER MaxLines
    Maximum allowed line count per SKILL.md. Defaults to 500.

.EXAMPLE
    ./scripts/validate-skills.ps1
    ./scripts/validate-skills.ps1 -MaxLines 400
    ./scripts/validate-skills.ps1 -SkillsPath 'some/other/skills'
#>
param(
    [string]$SkillsPath = '.github/plugins/pptb/skills',
    [int]$MaxLines = 500
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$resolvedSkillsPath = Join-Path $repoRoot $SkillsPath

if (-not (Test-Path $resolvedSkillsPath)) {
    throw "Skills directory not found at $resolvedSkillsPath"
}

# ---------------------------------------------------------------------------
# 1. Discover every SKILL.md under the skills directory
# ---------------------------------------------------------------------------
$skillFiles = @(Get-ChildItem -Path $resolvedSkillsPath -Filter 'SKILL.md' -Recurse -File |
    Sort-Object FullName)

if ($skillFiles.Count -eq 0) {
    throw "No SKILL.md files found under $resolvedSkillsPath."
}

Write-Host "Checking $($skillFiles.Count) SKILL.md file(s) against a $MaxLines-line limit...`n" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 2. Count lines in each and check against the limit
# ---------------------------------------------------------------------------
$failures = [System.Collections.Generic.List[string]]::new()
$checked = 0
$skipped = 0

foreach ($file in $skillFiles) {
    $skillName = Split-Path (Split-Path $file.FullName -Parent) -Leaf
    $lineCount = @(Get-Content -Path $file.FullName).Count

    if ($lineCount -eq 0) {
        Write-Host "  SKIP  $skillName (empty SKILL.md)" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    $checked++

    if ($lineCount -ge $MaxLines) {
        Write-Host "  FAIL  $skillName ($lineCount lines, limit $MaxLines)" -ForegroundColor Red
        $failures.Add("$skillName is $lineCount lines (limit $MaxLines) - move detail to references/")
    } else {
        Write-Host "  OK    $skillName ($lineCount lines)" -ForegroundColor Green
    }
}

# ---------------------------------------------------------------------------
# 3. Report
# ---------------------------------------------------------------------------
Write-Host ""
if ($skipped -gt 0) {
    Write-Host "$skipped empty stub(s) skipped." -ForegroundColor DarkGray
}

if ($failures.Count -eq 0) {
    Write-Host "All $checked SKILL.md file(s) are under $MaxLines lines." -ForegroundColor Green
    exit 0
}

Write-Host "$($failures.Count) of $checked SKILL.md file(s) exceed $MaxLines lines:" -ForegroundColor Red
foreach ($failure in $failures) {
    Write-Host "  - $failure" -ForegroundColor Red
}
exit 1
