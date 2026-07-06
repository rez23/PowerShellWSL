<#
.SYNOPSIS
    Installs a WSL distribution.
.DESCRIPTION
    This function installs a specified Windows Subsystem for Linux (WSL) distribution using wsl.exe.
.PARAMETER Name
    The name of the WSL distribution to install (e.g., "Ubuntu-20.04", "Debian").
.PARAMETER Version
    The WSL version to use for the distribution (1 or 2). Default is 2.
.PARAMETER InstallLocation
    Optional. The path to the local installation file for the distribution. If not provided, the distribution will be installed from the Microsoft Store.
.COMPONENT
    Windows Subsystem for Linux (WSL)
.EXAMPLE
    # Install Ubuntu 20.04 from C:\WSL\Ubuntu
    Install-WslDistribution -Name "Ubuntu-20.04" -Version 2 -InstallLocation "C:\WSL\Ubuntu"

    # Install Debian from the Microsoft Store
    Install-WslDistribution -Name "Debian" -Version 2
.NOTES
    Requires WSL to be installed. Ensure you have the necessary permissions to perform this operation.
#>
function Install-WslDistribution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ArgumentCompleter({ 
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
            Find-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
        })]
        [Alias("Distro")]
        [string]$Distribution,
        [Parameter(Mandatory = $false, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
            Find-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
        })]
        [string]$Name = $Distribution,
        [Parameter(Mandatory = $false, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet(1, 2)]
        [int]$Version = 2,
        [Parameter(Mandatory = $false)]
        [switch]$EnableWsl1,
        [Parameter(Mandatory = $false)]
        [switch]$FixedVHD,
        [Parameter(Mandatory = $false)]
        [string]$FromFile,
        [Parameter(Mandatory = $false)]
        [switch]$Legacy,
        [Parameter(Mandatory = $false)]
        [switch]$NoDistribution,
        [Parameter(Mandatory = $false)]
        [switch]$NoLaunch,
        [Parameter(Mandatory = $false)]
        [long]$VHDSize,
        [Parameter(Mandatory = $false)]
        [string]$URLDownload,
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter({ 
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
            Invoke-WslCommand -Command "ls $wordToComplete*" 
        })]
        [string]$Location
    )

    if ((-not $Distribution) -and (-not $Name)) {
        throw (New-WslErrorRecord @{
            Message      = "Missing required distribution name."
            ErrorId      = "PowerShellWSLInstallMissingName"
            Distribution = $Distribution
            WslArgs      = $null
            ExitCode     = $null
            StdErr       = $null
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    } else {
        if (-not $Distribution) {
            $Distribution = $Name
        }
    }
    $WslArgs = $PSBoundParameters.GetEnumerator() | 
    Remove-StdPsArgsParameter -ArgToRemove @('Distribution') |
    Convert-PsArgsToWsl

    # Check if the distribution is already installed
    $ExistingDistro = Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue
    if ($ExistingDistro) {
        throw (New-WslErrorRecord @{
            Message      = "WSL distribution is already installed."
            ErrorId      = "PowerShellWSLInstallAlreadyInstalled"
            Distribution = $Distribution
            WslArgs      = (@('--install', $Distribution) + $WslArgs) -join ' '
            ExitCode     = $null
            StdErr       = $null
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    }

    $AvailableDistro = Find-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue
    if (-not $AvailableDistro) {
        throw (New-WslErrorRecord @{
            Message      = "WSL distribution is not available for installation."
            ErrorId      = "PowerShellWSLInstallDistributionUnavailable"
            Distribution = $Distribution
            WslArgs      = (@('--install', $Distribution) + $WslArgs) -join ' '
            ExitCode     = $null
            StdErr       = $null
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    }

    Write-Information "Installing WSL distribution '$Distribution' from $(if ($Location) { "'$Location'" } else { "Microsoft Store" })..."
    $StdErr, $WslOutput, $Res = Invoke-WslCmdWrapper -WslArgs @('--install', $Distribution) + $WslArgs -ErrorAction Stop

    if ($Res -ne 0) {
        throw (New-WslErrorRecord @{
            Message      = "Failed to install WSL distribution with message: '$StdErr'"
            ErrorId      = "PowerShellWSLInstallFailed"
            Distribution = $Distribution
            WslArgs      = (@('--install', $Distribution) + $WslArgs) -join ' '
            ExitCode     = $Res
            StdErr       = ($StdErr | Out-String).Trim()
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    }

    Write-Information "Installation of '$Distribution' completed successfully."
}