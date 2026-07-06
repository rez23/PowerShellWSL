Describe 'Get-WslStatus (Integration)' -Tag Integration {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    It 'queries WSL status' {
        {
            Get-WslStatus -ErrorAction Stop | Out-Null
        } | Should -Not -Throw
    }
}
