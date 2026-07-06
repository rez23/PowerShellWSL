<#
.SYNOPSIS
    Reclaims WSL virtual drives free space.
.DESCRIPTION
    This function shuts down all WSL instances and optimizes the virtual drives used by Windows Subsystem for Linux (WSL). 
    It retrieves the paths of .vhdx files in the Docker and Windows Packages directories within the user's local 
    application data folder and optimizes them using the Optimize-VHD cmdlet.
.EXAMPLE
    # Reclaim virtual drives used by WSL
    Optimize-WslVirtualDrives -Docker -InformationAction Continue
.NOTES
    Requires WSL to be installed and the Optimize-VHD cmdlet to be available (part of the Hyper-V module). 
    Ensure you have the necessary permissions to perform these operations.
.ROLE
    Administrator
#>
function Optimize-WslVirtualDrives {
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Docker,
        [Parameter(Mandatory = $false)]
        [switch]$Wsl
    )
    
    # check if I am running as administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Cannot run Optimize-VHD. Administrator privileges are required."
    }

    Write-Information "Shutting down all WSL machines..."
    wsl --shutdown 

    $WslFolders = Get-WslDistributionPath | Select-Object -ExpandProperty VhdFile
    $WslFolders | ForEach-Object {
        if (([System.IO.File]::Exists($_))) {
            if ((-not $Docker) -and (-not $Wsl)) {
                Write-Verbose "No optimization mode specified. Optimizing both Docker and WSL virtual drives."
                $Docker = $true
                $Wsl = $true
            }
            
            if ($Docker -and $_ -match 'docker') {
                Write-Information "Optimizing Docker virtual drive: '$_'"
                Optimize-VHD $_ -Mode Full
            }

            if ($Wsl -and $_ -match 'wsl') {
                Write-Information "Optimizing WSL virtual drive: '$_'"
                Optimize-VHD $_ -Mode Full
            }
        } else {
            throw "The specified path '$_' does not exist or is not a valid file."
        }
    }
}