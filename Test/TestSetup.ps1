$TestRoot = Split-Path -Parent $PSCommandPath
$RepoRoot = Split-Path -Parent $TestRoot
$ManifestPath = Join-Path $RepoRoot 'PowerShellWSL.psd1'

Import-Module $ManifestPath -Force