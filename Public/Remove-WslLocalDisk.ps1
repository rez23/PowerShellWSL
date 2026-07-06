function Remove-WslLocalDisk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        # Custom mounted devices directly based on WSL output 
        [ValidateScript({
                (Get-CimInstance Win32_DiskDrive | Where-Object { $_.DeviceID -eq $_ }).Count -lt 1
            })]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                
                # Get the list of disk drives from the system and filter based on the user's input
                Get-CimInstance Win32_DiskDrive |  Where-Object { $_.DeviceID -like "$wordToComplete*" } | ForEach-Object { $_.DeviceID }
            })]
        [string]$Disk
    )

    process {
        # Check if the distribution is running
        $CurrentDistro = Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue
        if (-not $CurrentDistro) {
            throw (New-WslErrorRecord @{
                    Message      = "WSL distribution not found."
                    ErrorId      = "PowerShellWSLDistributionNotFound"
                    Distribution = $Distribution
                    WslArgs      = "--unmount $Disk"
                    ExitCode     = $null
                    StdErr       = $null
                    WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }
        
        Write-Information "Unmounting disk '$Disk' from WSL global context..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--unmount', $Disk) -ErrorAction Stop
        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                    Message      = "Failed to unmount local disk from WSL with message: '$StdErr'"
                    ErrorId      = "PowerShellWSLUnmountDiskFailed"
                    Distribution = $Distribution
                    WslArgs      = "--unmount $Disk"
                    ExitCode     = $Res
                    StdErr       = ($StdErr | Out-String).Trim()
                    WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }
        else {
            Write-Information "Successfully unmounted disk '$Disk' from WSL global context."
        }
    }
}