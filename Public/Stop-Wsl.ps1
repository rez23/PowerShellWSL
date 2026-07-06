function Stop-Wsl {
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force
    )

    if ($Force) {
        Write-Information "Shutting down WSL distributions via '--shutdown --force'..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--shutdown', '--force') -ErrorAction Stop
        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                Message      = "Failed to shut down WSL with message: '$StdErr'"
                ErrorId      = "PowerShellWSLShutdownFailed"
                Distribution = $null
                WslArgs      = "--shutdown --force"
                ExitCode     = $Res
                StdErr       = ($StdErr | Out-String).Trim()
                WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
            })
        }
        else {
            Write-Information "Successfully shut down WSL."
        }
    } else {
        Write-Information "Shutting down WSL via '--shutdown'..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--shutdown') -ErrorAction Stop
        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                Message      = "Failed to shut down WSL with message: '$StdErr'"
                ErrorId      = "PowerShellWSLShutdownFailed"
                Distribution = $null
                WslArgs      = "--shutdown"
                ExitCode     = $Res
                StdErr       = ($StdErr | Out-String).Trim()
                WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
            })
        }
        else {
            Write-Information "Successfully shut down WSL."
        }
    }
}