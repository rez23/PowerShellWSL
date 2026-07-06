function Stop-WslDistribution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | Where-Object { $_.Status -eq [WslDistributionStatus]::Running } | ForEach-Object { $_.Distribution } 
            })]
        [Alias("Distro", "Name")]
        [string]$Distribution
    )

    process {
        $ActualRunningDistro = Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq [WslDistributionStatus]::Running }
        if (-not $ActualRunningDistro) {
            throw (New-WslErrorRecord @{
                Message      = "WSL distribution is not currently running."
                ErrorId      = "PowerShellWSLStopInvalidState"
                Distribution = $Distribution
                WslArgs      = "--terminate $Distribution"
                ExitCode     = $null
                StdErr       = $null
                WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
            })
        }

        Write-Information "Stopping WSL distribution '$Distribution'..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--terminate', $Distribution) -ErrorAction Stop

        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                Message      = "Failed to stop WSL distribution with message: '$StdErr'"
                ErrorId      = "PowerShellWSLStopFailed"
                Distribution = $Distribution
                WslArgs      = "--terminate $Distribution"
                ExitCode     = $Res
                StdErr       = ($StdErr | Out-String).Trim()
                WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
            })
        }
    }
}