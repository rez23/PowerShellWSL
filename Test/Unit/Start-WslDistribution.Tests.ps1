Describe 'Start-WslDistribution' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    InModuleScope PowerShellWSL {
        BeforeEach {
            Mock Get-WslStatus { [pscustomobject]@{ WSL = '2.4.13' } }
            Mock Get-WslDistribution { $null }
        }

        It 'accepts ValueFromPipelineByPropertyName for Distribution' {
            try {
                [pscustomobject]@{ Distribution = 'Ubuntu' } | Start-WslDistribution -ErrorAction Stop
                throw 'Expected exception was not thrown.'
            }
            catch {
                $_.FullyQualifiedErrorId | Should -Be 'PowerShellWSLStartInvalidState'
            }
        }
    }
}
