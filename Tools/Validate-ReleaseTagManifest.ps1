[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Tag,

    [string]$ManifestPath = './PowerShellWSL.psd1'
)

$ErrorActionPreference = 'Stop'

if ($Tag -notmatch '^v(?<version>\d+\.\d+\.\d+)(?:-(?<prerelease>[0-9A-Za-z.-]+))?$') {
    throw "Tag '$Tag' is not valid. Expected vMAJOR.MINOR.PATCH or vMAJOR.MINOR.PATCH-prerelease."
}

$TagVersion = $Matches.version
$TagPrerelease = $Matches.prerelease

$Manifest = Import-PowerShellDataFile -Path $ManifestPath
$ManifestVersion = [string]$Manifest.ModuleVersion
$ManifestPrerelease = [string]$Manifest.PrivateData.PSData.Prerelease

if ($ManifestVersion -ne $TagVersion) {
    throw "Manifest ModuleVersion '$ManifestVersion' does not match tag version '$TagVersion'."
}

if ([string]::IsNullOrWhiteSpace($TagPrerelease)) {
    if (-not [string]::IsNullOrWhiteSpace($ManifestPrerelease)) {
        throw "Stable tag '$Tag' requires empty Prerelease in manifest, found '$ManifestPrerelease'."
    }
}
else {
    if ([string]::IsNullOrWhiteSpace($ManifestPrerelease)) {
        throw "Prerelease tag '$Tag' requires PrivateData.PSData.Prerelease='$TagPrerelease' in manifest."
    }

    if ($ManifestPrerelease -ne $TagPrerelease) {
        throw "Manifest Prerelease '$ManifestPrerelease' does not match tag prerelease '$TagPrerelease'."
    }
}

Write-Host "Tag/manifest validation passed for $Tag"
