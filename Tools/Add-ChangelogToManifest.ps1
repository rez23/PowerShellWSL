
$ProjectModuleRoot = (Get-Item "$PSScriptRoot").Parent.FullName
$ProjectModuleRoot = (Get-Item $ProjectModuleRoot).FullName

if (-not (Test-Path $ProjectModuleRoot)) {
    throw "Project module root path '$ProjectModuleRoot' does not exist."
}

$ProjectName = (Get-Item $ProjectModuleRoot).BaseName

if (-not (Test-Path "$ProjectModuleRoot\$ProjectName.psd1")) {
    throw "Manifest file '$ProjectModuleRoot\$ProjectName.psd1' does not exist."
}

function Get-VersionFromGit {
    $gitDescribe = git describe --tags --abbrev=0 2>$null
    if ($LASTEXITCODE -eq 0) {
        $gitDescribe -replace "v", ""
    }
    else {
        throw "Git command failed"
    }
}

function Filter-ChangeLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$ChangeLog
    )
    process {
        if ($ChangeLog -match 'feat:|docs:|fix:') {
            $ChangeLog
        }
    }
}

$ChangeLog = @"
# Release $(Get-VersionFromGit) Notes

$(@(& "$PSScriptRoot\Generate-Changelog.ps1" -Nolinks | Filter-ChangeLog) -join "`n")
"@

$ChangeLog 

Update-ModuleManifest `
    -Path "$ProjectModuleRoot\$ProjectName.psd1" `
    -ReleaseNotes  $ChangeLog  #>