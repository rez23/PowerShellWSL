Describe 'Get-WslConfig' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    InModuleScope PowerShellWSL {
        BeforeEach {
            Mock Invoke-WslCommand { 'ok' }
        }

        It 'accepts ValueFromPipeline and reads Distribution from input object' {
            $Result = [pscustomobject]@{ Distribution = 'Ubuntu' } | Get-WslConfig

            $Result | Should -Be 'ok'
            Assert-MockCalled Invoke-WslCommand -Times 1 -Exactly -ParameterFilter {
                $Distribution -eq 'Ubuntu' -and $Command -eq 'cat /etc/wsl.conf'
            }
        }
    }
}
