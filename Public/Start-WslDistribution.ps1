function Start-WslDistribution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | Where-Object { $_.Status -eq [WslDistributionStatus]::Stopped } | ForEach-Object { $_.Distribution } 
            })]
        [Alias("Distro", "Name")]
        [string]$Distribution
    )

    $ActualStoppedDistro = Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq [WslDistributionStatus]::Stopped }
    if (-not $ActualStoppedDistro) {
        throw (New-WslErrorRecord @{
            Message      = "WSL distribution is not currently stopped."
            ErrorId      = "PowerShellWSLStartInvalidState"
            Distribution = $Distribution
            WslArgs      = "-d $Distribution"
            ExitCode     = $null
            StdErr       = $null
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    }

    if (-not $Distribution) {
        Write-Verbose "No distribution name specified. Using the default WSL distribution."
        $WslDefaultDistro = Get-WslDistribution -Default -ErrorAction Stop
        $Distribution = $WslDefaultDistro.Distribution
    }
    
    Write-Information "Starting WSL distribution '$Distribution'..."
    wsl.exe -d $Distribution

    if ($LASTEXITCODE -ne 0) {
        throw (New-WslErrorRecord @{
            Message      = "Failed to start WSL distribution."
            ErrorId      = "PowerShellWSLStartFailed"
            Distribution = $Distribution
            WslArgs      = "-d $Distribution"
            ExitCode     = $LASTEXITCODE
            StdErr       = $null
            WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
        })
    }
}