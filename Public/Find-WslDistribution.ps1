<#
.SYNOPSIS
    Finds installable WSL distributions available for download from the Microsoft Store.
.DESCRIPTION
    This function retrieves a list of installable Windows Subsystem for Linux (WSL) 
    distributions that are available for download from the Microsoft Store. 
    It allows you to filter the results by distribution name, friendly name, or whether
    the distribution is already installed on the system.
.PARAMETER Name
    Optional. The name of the WSL distribution to search for. This can be a partial or full name. 
    If not specified, all available distributions will be returned.
.PARAMETER FriendlyName
    Optional. A switch to indicate that the output should include the friendly names of the 
    distributions instead of their technical names.
.PARAMETER Installed
    Optional. A switch to filter the results to only include distributions that are already installed on the system.
.COMPONENT
    Windows Subsystem for Linux (WSL)
.NOTES
    Requires WSL to be installed.
#>
function Find-WslDistribution {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [Alias("Distro", "Name")]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Find-WslDistribution | Where-Object { ($_.Distribution -like "$wordToComplete*") -or ($_.FriendlyName -like "$wordToComplete*") } | ForEach-Object { $_.Distribution } })]
        [string]$Distribution,
        [Parameter(Mandatory = $false)]
        [switch]$FriendlyName,
        [Parameter(Mandatory = $false)]
        [switch]$Installed
    )
 
    process {
        # Get the list of installed distributions
        $StdErr, $WslOutput, $Res = Invoke-WslCmdWrapper -WslArgs @('--list', '--online') -ErrorAction Stop
        $WslInstalledDistros = Get-WslDistribution -ErrorAction Stop
        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                Message      = "Failed to retrieve installable WSL distributions with message: '$StdErr'"
                ErrorId      = "PowerShellWSLOnlineListFailed"
                Distribution = $null
                WslArgs      = "--list --online"
                ExitCode     = $Res
                StdErr       = ($StdErr | Out-String).Trim()
                WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
            })
        }

        # Get the list of online distributions from the WSL output
        $WslOnlineDistro = $WslOutput -split "`n" | ConvertTo-CleanedWslString  | Select-Object -Skip 4
        $Serialized = $WslOnlineDistro | Foreach-Object {
            $Elem = $_ -split "\s+", ""

            if ([string]::IsNullOrEmpty($Elem) -or 
                [string]::IsNullOrWhiteSpace($Elem)) {
                return
            }

            $DistroName = $Elem[0]
            $DistroFriendlyName = $Elem[1..($Elem.Count - 1)] -join " "
            $IsDistroInstalled = ($WslInstalledDistros | Where-Object { $_.Distribution -eq $DistroName }).Count -gt 0

            [pscustomobject]@{
                Distribution = $DistroName
                FriendlyName = $DistroFriendlyName
                IsInstalled  = $IsDistroInstalled
            }
        }

        if ($Installed) {
            $Serialized = $Serialized | Where-Object { $_.IsInstalled }
            if (-not $Serialized) {
                Write-Verbose "No installed distributions found."
            } else {
                $Serialized
            } 
        }

        if ($FriendlyName) {
            $Serialized = $Serialized | Select-Object -Property FriendlyName
        }

        if ($Distribution) {
            $Serialized = $Serialized | Where-Object { $_.Distribution -like $Distribution -or $_.FriendlyName -like $Distribution }
            if (-not $Serialized) {
                Write-Verbose "'$Distribution' not found in the list of available distributions."
            } else {
                $Serialized
            } 
        } else { 
            $Serialized
        }
    }
}