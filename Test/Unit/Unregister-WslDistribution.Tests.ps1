Describe 'Unregister-WslDistribution' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    InModuleScope PowerShellWSL {
        BeforeEach {
            Mock Invoke-WslCmdWrapper { @('', '', 0) }
        }

        It 'accepts ValueFromPipelineByPropertyName for Distribution' {
            {
                [pscustomobject]@{ Distribution = 'Ubuntu' } | Unregister-WslDistribution -ErrorAction Stop
            } | Should -Not -Throw

            Assert-MockCalled Invoke-WslCmdWrapper -Times 1 -Exactly -ParameterFilter {
                $WslArgs[0] -eq '--unregister' -and $WslArgs[1] -eq 'Ubuntu'
            }
        }
    }
}
