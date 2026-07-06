<#
.SYNOPSIS
    Exports a WSL installed distribution to a specified file.
.DESCRIPTION
    This function exports a specified installed Windows Subsystem for Linux (WSL) distribution to a file.
    So that you can have a backup of your WSL distribution or move it to another machine. 
    It allows you to specify the distribution name, destination file path, additional options, 
    and the export format via '-FormatAs' parameter.
.PARAMETER Distribution
    The name of the WSL distribution to export (e.g., "Ubuntu-20.04", "Debian").
.PARAMETER Destination
    The file path where the exported distribution will be saved. This can be a local path or
    a network path. Ensure that you have write permissions to the specified location.
.PARAMETER FormatAs
    Optional. Specifies the format in which to export the WSL distribution. 
    Valid values are "tar", "vhdx", "tar.gz", "tar.vz", and "tar.xz". The default format is "tar".
.PARAMETER AdditionalOptions
    Optional. Additional command-line options to pass to the 'wsl.exe --export' command
#>
function Export-WslVhdToFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } })]
        [string]$Distribution,
        [Parameter(Mandatory = $false)]
        [string]$Destination,
        [Parameter(Mandatory = $false)]
        [ValidateSet("tar", "vhdx", "tar.gz", "tar.vz", "tar.xz")]
        [string]$FormatAs,
        [Parameter(Mandatory = $false)]
        [string]$AdditionalOptions
    )
    process {
        if (-not $Distribution) {
            Write-Verbose "No distribution name specified. Using the default WSL distribution."
            $WslDefaultDistro = Get-WslDistribution -Default -ErrorAction SilentlyContinue
            $Distribution = $WslDefaultDistro.Distribution
        }

        if (-not $Destination) {
            $Destination = "$PWD\$Distribution-$(Get-Date -Format 'yyyyMMdd-HHmmss').tar"
        }

        $CurrentDistro = Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue
        if (-not $CurrentDistro) {
            throw (New-WslErrorRecord @{
                    Message      = "WSL distribution not installed."
                    ErrorId      = "PowerShellWSLDistributionNotInstalled"
                    Distribution = $Distribution
                    WslArgs      = "--export $Distribution $Destination $AdditionalOptions --format $FormatAs"
                    ExitCode     = $null
                    StdErr       = $null
                    WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }
        else {
            if ($CurrentDistro.Status -eq [WslDistributionStatus]::Running) {
                Write-Warning "'$Distribution' is currently running. Shutting down..."
                Stop-WslDistribution -Distribution $Distribution -ErrorAction Stop
            }
        }

        $DestExtension = [System.IO.Path]::GetExtension($Destination).TrimStart('.').ToLower()
    
        if (-not $FormatAs) {
            # TODO: need to be rewrites
            if ($DestExtension -and ($DestExtension -in @("tar", "vhdx", "tar.gz", "tar.vz", "tar.xz"))) {
                Write-Verbose "No export format specified. Using: '$DestExtension' from '$Destination'."
                $FormatAs = $DestExtension
            }
            else {
                Write-Verbose "No export format specified. Defaulting to 'tar' format."
                $FormatAs = "tar"
            }
        }
        else {
            if ($DestExtension -ne $FormatAs) {
                Write-Warning "Extensions '-Destination' ('$DestExtension') and -FormatAs ('$FormatAs') mismatch. Using '-FormatAs' value instead." 
                $Destination = [System.IO.Path]::ChangeExtension($Destination, $FormatAs)
            } 
        }
    

        Write-Information "Exporting WSL distribution '$Distribution' to file '$Destination'..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--export', $Distribution, $Destination, $AdditionalOptions, '--format', $FormatAs) -ErrorAction Stop
        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                    Message      = "Failed to export WSL distribution with message: '$StdErr'"
                    ErrorId      = "PowerShellWSLExportFailed"
                    Distribution = $Distribution
                    WslArgs      = @('--export', $Distribution, $Destination, $AdditionalOptions, '--format', $FormatAs) -join ' '
                    ExitCode     = $Res
                    StdErr       = ($StdErr | Out-String).Trim()
                    WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }
        else {
            Write-Information "Successfully exported WSL distribution '$Distribution' to file '$Destination'."
        }
    }
}