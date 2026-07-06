<#
.SYNOPSIS
    Retrieves the WSL configuration for a specified distribution or the global WSL configuration.
.DESCRIPTION
    This function retrieves the WSL configuration for a specified Windows Subsystem for Linux (WSL) 
    distribution or the global WSL configuration. If no distribution is specified, it retrieves the
    global configuration from the .wslconfig file in the user's profile. If a distribution is 
    specified, it retrieves the configuration from the /etc/wsl.conf file within that distribution.
.PARAMETER Distribution
    The name of the WSL distribution for which to retrieve the configuration. If not specified,
    the function retrieves the global WSL configuration.
.COMPONENT
    Windows Subsystem for Linux (WSL)
.NOTES
    Requires WSL to be installed and the specified distribution to be available.
    Supports pipeline input for the Distribution parameter, allowing you to pass a WSL distribution object directly. 
#>
function Get-WslConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
            })]
        [Alias("Distro", "Name")]
        [string]$Distribution
    )

    process {
        $IsLocalWslConfigif = (-not $Distribution)

        if ($IsLocalWslConfigif) {
            Write-Information "No distribution specified. Retrieving global WSL configuration ($env:USERPROFILE\.wslconfig):"
            if (Test-Path -Path "$env:USERPROFILE\.wslconfig") {
                Write-Verbose "Reading WSL global config from '$env:USERPROFILE\.wslconfig'..."
                ConvertFrom-RawWslCmdOut -RawConfig (Get-Content -Path "$env:USERPROFILE\.wslconfig" -ErrorAction SilentlyContinue | Out-String)
            }
            else {
                Write-Verbose "No global .wslconfig file found on system. Nothing to retrieve."
            }
        }
        else {
            # use default distro if no distribution is specified (not really possible becouse no Distribution get local config)
            $Distribution = if (-not $Distribution) { Get-WslDistribution -Default | Select-Object -ExpandProperty Distribution } else { $Distribution }
            Write-Information "Retrieving WSL configuration for distribution '$Distribution' (/etc/wsl.conf):"
            Invoke-WslCommand -Distribution $Distribution -Command "cat /etc/wsl.conf" -ErrorAction SilentlyContinue
        }
    }
}