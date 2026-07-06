[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git executable not found in PATH.'
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

if (-not (Test-Path '.githooks')) {
    throw '.githooks folder not found in repository root.'
}

git config --local core.hooksPath .githooks
Write-Host 'Git hooks enabled for this repository (local core.hooksPath=.githooks).'
Write-Host 'Pre-push hook will run: ./Tools/Run-Tests.ps1'
