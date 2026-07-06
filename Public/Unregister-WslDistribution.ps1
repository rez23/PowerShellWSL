<#
.SYNOPSIS
    Unregisters a WSL distribution.
.DESCRIPTION
    This function unregisters a specified WSL distribution, effectively removing it from the system.
.PARAMETER Distribution
    The name of the WSL distribution to unregister.
.EXAMPLE
    # Unregister a WSL distribution
    Unregister-WslDistribution -Distribution "Ubuntu-20.04"
.NOTES
    Requires WSL to be installed. Ensure you have the necessary permissions to perform this operation.
#>
function Unregister-WslDistribution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
            })]
        [Alias("Distro", "Name")]
        [string]$Distribution
    )

    process {
        Write-Information "Unregistering WSL distribution '$Distribution'..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--unregister', $Distribution) -ErrorAction Stop

        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                Message      = "Failed to unregister WSL distribution with message: '$StdErr'"
                ErrorId      = "PowerShellWSLUnregisterFailed"
                Distribution = $Distribution
                WslArgs      = "--unregister $Distribution"
                ExitCode     = $Res
                StdErr       = ($StdErr | Out-String).Trim()
                WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
            })
        } else {
            Write-Information "Successfully unregistered WSL distribution '$Distribution'."
        }
    }
} 