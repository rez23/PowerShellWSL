Describe 'Invoke-WslCommand (Integration)' -Tag Integration {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    It 'executes a simple command in default distro' {
        $Distros = Get-WslDistribution
        if (-not $Distros -or $Distros.Count -eq 0) {
            Write-Warning 'No WSL distributions installed. Test skipped.'
            return
        }

        $Result = Invoke-WslCommand -Command 'echo banana' -ErrorAction Stop
        $Result | Should -Match 'banana'
    }
}
