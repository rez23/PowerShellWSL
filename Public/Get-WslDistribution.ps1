<#
.SYNOPSIS
    Gets the list of installed WSL distributions.
.DESCRIPTION
    This function retrieves the list of installed Windows Subsystem for Linux (WSL) distributions on the system. It can filter distributions by name, default status, or running status.
.PARAMETER Name
    Optional. The name of the WSL distribution to retrieve. If specified, only the distribution with this name will be returned.
.PARAMETER Default
    Optional. A switch to filter and return only the default WSL distribution.
.PARAMETER Status
    Optional. A filter to return distributions based on their running status (e.g., Running, Stopped). Accepts values from the WslDistributionStatus enumeration.
.EXAMPLE
    # Get all installed WSL distributions
    Get-WslDistribution

    # Get a specific distribution by name
    Get-WslDistribution -Name "Ubuntu-20.04"

    # Get the default distribution
    Get-WslDistribution -Default

    # Get distributions with a specific status
    Get-WslDistribution -Status Running
.NOTES
    Requires WSL to be installed. Ensure you have the necessary permissions to perform this operation.
.COMPONENT
    Windows Subsystem for Linux (WSL)
#>
function Get-WslDistribution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias("Distro", "Name")]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
            })]
        [string]$Distribution,
        [Parameter(Mandatory = $false)]
        [switch]$Default,
        [Parameter(Mandatory = $false)]
        [WslDistributionStatus]$Status
    )

    # WSL command parameters
    $WslParams = @('--list', '--verbose', '--all')

    $Stdout, $WslOutput, $Res = Invoke-WslCmdWrapper -WslArgs $WslParams -ErrorAction Stop
    $Serialized = $WslOutput -split "`n" | ConvertTo-CleanedWslString | Select-Object -Skip 1 | Foreach-Object {
        $Elem = $_ -split "\s+", ""

        if ([string]::IsNullOrEmpty($Elem) -or 
            [string]::IsNullOrWhiteSpace($Elem)) {
            return
        }

        $IsDefault = $Elem[0] -match "\*"
        if ($IsDefault) {
            $Elem = $Elem | Select-Object -Skip 1
        }

        $WslDistributionPath = Get-WslDistributionPath -DistributionName $Elem[0] | Select-Object -ExpandProperty VhdFile
        [WslDistribution]::new(@{
                Distribution = $Elem[0]
                Version      = $Elem[2]
                Status       = $Elem[1]
                VhdFile      = $WslDistributionPath
                IsDefault    = $IsDefault
            })
    }

    if (-not $Serialized) {
        Write-Verbose "No installed distributions found. Run Install-WslDistribution"
    } else {
        if ($Distribution) {
            $Serialized = $Serialized | Where-Object { $_.Distribution -like $Distribution }
            if (-not $Serialized) {
                Write-Verbose "'$Distribution' not found on current system."
            }
            else {
                $Serialized
            } 
        } elseif ($Default) {
            $Serialized = $Serialized | Where-Object { $_.IsDefault }
            if (-not $Serialized) {
                Write-Verbose "No default distribution found."
            }
            else {
                $Serialized
            } 
        } elseif ($Status) {
            $Serialized = $Serialized | Where-Object { $_.Status -eq $Status }
            if (-not $Serialized) {
                Write-Verbose "No distributions found with status '$Status'."
            }
            else {
                $Serialized
            } 
        }
        else {
            $Serialized
        }
    }
}