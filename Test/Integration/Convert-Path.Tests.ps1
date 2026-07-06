Describe 'ConvertTo-WslPath/ConvertTo-WindowsPath (Integration)' -Tag Integration {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    It 'supports pipeline conversion round-trip' {
        $Distros = Get-WslDistribution
        if (-not $Distros -or $Distros.Count -eq 0) {
            Write-Warning 'No WSL distributions installed. Test skipped.'
            return
        }

        $WslPath = '.' | ConvertTo-WslPath -ErrorAction Stop
        $WinPath = $WslPath | ConvertTo-WindowsPath -ErrorAction Stop

        $WslPath | Should -Not -BeNullOrEmpty
        $WinPath | Should -Not -BeNullOrEmpty
    }
}
