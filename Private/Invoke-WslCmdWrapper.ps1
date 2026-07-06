$script:WinNativeArg = {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value.Length -eq 0) {
        return
    }

    if ($Value -notmatch '[\s"]') {
        return $Value
    }

    $escaped = $Value -replace '(\\*)"', '$1$1\"'
    $escaped = $escaped -replace '(\\+)$', '$1$1'

    '"' + $escaped + '"'
}

<#
.SYNOPSIS
    Executes a command in a specified WSL distribution.
.DESCRIPTION
    This function executes a specified command in a given Windows Subsystem for Linux (WSL) distribution. It allows you to specify the distribution, user, and whether to run the command as an administrator.
.PARAMETER WslArgs
    An array of arguments to pass to the WSL command.
.PARAMETER Command
    The command to execute in the WSL distribution.
.PARAMETER Shell
    The shell to use for executing the command. Default is "/bin/sh".
#>
function Invoke-WslCmdWrapper {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$WslArgs = @(),

        [Parameter(Mandatory = $false)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string]$Shell = "/bin/sh"
    )

    $argList = $WslArgs

    if ($Command) {
        $argList += @('--', $Shell, '-lc', $Command)
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'wsl.exe'
    $psi.Arguments = ($argList | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { & $script:WinNativeArg -Value $_ }) -join ' '    
    Write-Verbose "Executing command: '$($psi.FileName) $($psi.Arguments)'"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    [void]$proc.Start()

    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()

    $proc.WaitForExit()

    @(
        $stderr
        $stdout.TrimEnd("`r","`n")
        $proc.ExitCode
    )
}