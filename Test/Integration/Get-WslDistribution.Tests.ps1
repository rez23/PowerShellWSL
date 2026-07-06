Describe 'Get-WslDistribution (Integration)' -Tag Integration {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    It 'queries installed distributions' {
        {
            Get-WslDistribution -ErrorAction Stop | Out-Null
        } | Should -Not -Throw
    }
}
