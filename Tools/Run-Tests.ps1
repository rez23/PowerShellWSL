[CmdletBinding()]
param(
    [switch]$IncludeIntegration
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Module -ListAvailable -Name Pester)) {
    throw 'Pester is not installed. Install it with: Install-Module Pester -Scope CurrentUser -Force'
}

Import-Module Pester -MinimumVersion 5.0.0 -Force

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ModuleName = (Get-Item $RepoRoot).BaseName
$ManifestPath = Join-Path $RepoRoot "$ModuleName.psd1"

if (Test-Path $ManifestPath) {
    Import-Module $ManifestPath -Force
} else {
    throw "Manifest non trovato in: $ManifestPath"
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$TestsPath = Join-Path $RepoRoot 'Test'
$TagFilter = if ($IncludeIntegration) { @('Unit', 'Integration') } else { @('Unit') }

$Config = New-PesterConfiguration
$Config.Run.Path = $TestsPath
$Config.Run.PassThru = $true
$Config.Filter.Tag = $TagFilter
$Config.Output.Verbosity = 'Detailed'

$Result = Invoke-Pester -Configuration $Config

if ($Result.Failed.Count -gt 0) {
    exit 1
}
