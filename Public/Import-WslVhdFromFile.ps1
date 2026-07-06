<#
.SYNOPSIS
    Imports a WSL distribution from a VHD file.
.DESCRIPTION
    This function imports a WSL distribution from a specified VHD file. It allows you to specify the distribution name, VHD path, install location, and WSL version.
.PARAMETER Distribution
    The name of the WSL distribution to import.
.PARAMETER VhdPath
    The path to the VHD file to import.
.PARAMETER InstallLocation
    The location where the WSL distribution should be installed.
.PARAMETER WslVersion
    The version of WSL to use for the imported distribution. Valid values are 1 or 2. Default is 2.
.EXAMPLE
    # Import a WSL distribution from a VHD file
    Import-WslVhdFromFile -Distribution "Ubuntu-20.04" -VhdPath "C:\path\to\ubuntu.vhd" -InstallLocation "C:\WSL\Ubuntu-20.04"
.NOTES
    Requires WSL to be installed. Ensure you have the necessary permissions to perform this operation.
#>
function Import-WslVhdFromFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ArgumentCompleter({ 
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
            Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
        })]
        [Alias("Distro")]
        [string]$Distribution,
        [Parameter(Mandatory = $true)]
        [string]$VhdPath,
        [Parameter(Mandatory = $true)]
        [string]$InstallLocation,
        [Parameter(Mandatory = $false)]
        [ValidateSet(1,2)]
        [int]$WslVersion=2
    )

    Write-Information "Importing WSL distribution from VHD '$VhdPath' as '$Distribution'..."
    
    $WslArgsToPass = @()
    if (-not $InstallLocation) {
        Write-Verbose "No install location specified. Using default WSL install location."
        $WslArgsToPass += @("--import-in-place", $Distribution, $VhdPath)
    } else {
        $WslArgsToPass += @("--import", $Distribution, $InstallLocation, $VhdPath)
    }
    
    $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs $WslArgsToPass

    if ($Res -ne 0) {
        throw (New-WslErrorRecord @{
            Message      = "Failed to import WSL distribution from VHD with message: '$StdErr'"
            ErrorId      = "PowerShellWSLImportFailed"
            Distribution = $Distribution
            WslArgs      = ($WslArgsToPass -join ' ')
            ExitCode     = $Res
            StdErr       = ($StdErr | Out-String).Trim()
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    }
}