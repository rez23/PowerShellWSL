<#
.SYNOPSIS
    Gets the paths of virtual drives used by WSL.
.DESCRIPTION
    This function retrieves the paths of virtual drives used by Windows Subsystem for Linux (WSL). It searches for .vhdx files in the Docker and Windows Packages directories within the user's local application data folder.
.EXAMPLE
    # Get the paths of virtual drives used by WSL
    Get-WslDistributionPath
#>
function Get-WslDistributionPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$DistributionName
    )
    
    # Get and return the path of the specified WSL distribution
    Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss |
    ForEach-Object { Get-ItemProperty $_.PSPath } |
    Where-Object { if ($DistributionName) { $_.DistributionName -eq $DistributionName } else { $true } } |
    Select-Object `
        DistributionName, 
        @{Name='VhdFile';Expression={
            $DistributionName = $_.DistributionName
            $BasePath = $_.BasePath -replace '([\\]*(\?)[\\]*)',''

            # Search for VHDX files in the BasePath
            $VhdFiles = Get-ChildItem -Path $BasePath -Filter *.vhdx -Recurse -ErrorAction Stop
            $VhdFiles.FullName
        }}
}