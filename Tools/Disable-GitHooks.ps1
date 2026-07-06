[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git executable not found in PATH.'
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

git config --local --unset core.hooksPath 2>$null
Write-Host 'Repository custom git hooks path disabled (local core.hooksPath unset).'