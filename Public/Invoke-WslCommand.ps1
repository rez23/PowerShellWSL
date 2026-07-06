<#
.SYNOPSIS
    Executes a command in a specified WSL distribution.
.DESCRIPTION
    This function executes a specified command in a given Windows Subsystem for Linux (WSL) distribution. It allows you to specify the distribution, user, and whether to run the command as an administrator.
.PARAMETER Command
    The command to execute in the WSL distribution.
.PARAMETER Distro
    The name of the WSL distribution in which to execute the command (e.g., "Ubuntu-20.04", "Debian").
.PARAMETER User
    Optional. The user under which to execute the command in the WSL distribution. If not specified, the default user for the distribution will be used.
.PARAMETER Password
    Optional. A secure string representing the password for the specified user. This is required if you want to run the command as a different user and the distribution requires authentication.
.PARAMETER AsAdmin
    Optional. A switch to indicate that the command should be executed with administrative privileges in the WSL distribution.
.PARAMETER Shell
    Optional. The shell to use for executing the command. Default is "/bin/sh". You can specify other shells like "/bin/bash", "/bin/zsh", etc., 
    if they are available in the distribution.
.PARAMETER ShellType
    Optional. Specifies the type of shell to use. Valid values are "Login", "Standard", or "None". This parameter affects how the shell initializes the environment.
.EXAMPLE
    # Execute a command in the Ubuntu-20.04 distribution
    Invoke-WslCommand -Command "ls -la" -Distro "Ubuntu-20.04"
    # Execute a command as a specific user in the Debian distribution
    Invoke-WslCommand -Command "whoami" -Distro "Debian" -User "myuser" -Password (ConvertTo-SecureString "mypassword" -AsPlainText -Force)
.NOTES
    Requires WSL to be installed and the specified distribution to be available. Ensure you have the necessary permissions to perform this operation.
.COMPONENT
    Windows Subsystem for Linux (WSL)
#>
function Invoke-WslCommand {
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Command,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                Get-WslDistribution -Distribution "$wordToComplete*" | ForEach-Object { $_.Distribution } 
            })]
        [Alias("Distro", "Name")]
        [string]$Distribution,
        [Parameter(Mandatory = $false)]
        [string]$User,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [switch]$AsAdmin,
        [Parameter(Mandatory = $false)]
        # Get available shell directly from WSL
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

                $DistributionName = $fakeBoundParameters['Distribution']
                if (-not $DistributionName) {
                    $DistributionName = Get-WslDistribution -Default | Select-Object -ExpandProperty Distribution
                }

                # Get the list of supported filesystem types from the specified WSL distribution
                $AvavilableDisk = (Invoke-WslCommand -System -Command "awk '/^\// {print}' /etc/shells") -split "`n" | ForEach-Object { $_.Trim() }
                $AvavilableDisk | Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string]$Shell = "/bin/sh",
        [Parameter(Mandatory = $false)]
        [ValidateSet("Login", "Standard", "None")]
        [string]$ShellType,
        [Parameter(Mandatory = $false)]
        [switch]$System
    )

    process {
        $PsStandardArgs = @($PSBoundParameters.GetEnumerator()) 
    
        $WslArgs = $PsStandardArgs | 
        Remove-StdPsArgsFromWslArgs -ErrorAction Stop -ArgToRemove @('Command', 'Shell', 'Distribution') | 
        Convert-PsArgsToWsl -ErrorAction Stop
    
        $WslDistro = if ((-not $System) -and (-not $Distribution)) { 
            Write-Verbose "No distribution specified. Using the default WSL distribution."
            $Elem = Get-WslDistribution -Default
            $Distribution = $Elem.Distribution
            $Elem
        }
        else { 
            Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue 
        }

        if (-not $WslDistro) {
            throw (New-WslErrorRecord @{
                    Message = "WSL distribution not found."
                    ErrorId = "PowerShellWSLDistributionNotFound"
                    Distribution = $Distribution
                    WslArgs = ($WslArgs -join ' ')
                    ExitCode = $null
                    StdErr = $null
                    WslVersion = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }

        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs $WslArgs -Command $Command -Shell $Shell

        if ($Res -ne 0) {
            $DistributionDisplay = if ($Distribution) { $Distribution } else { "(default)" }

            throw (New-WslErrorRecord @{
                    Message = "WSL command execution failed"
                    ErrorId = "PowerShellWSLCommandFailed"
                    Distribution = $DistributionDisplay
                    WslArgs = ($WslArgs -join ' ')
                    ExitCode = $Res
                    StdErr = ($StdErr | Out-String).Trim()
                    WslVersion = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }
    
        ($StdOut -split "`n" | ConvertTo-CleanedWslString) -join "`n"
    }
}