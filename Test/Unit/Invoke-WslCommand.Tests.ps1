Describe 'Invoke-WslCommand' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    InModuleScope PowerShellWSL {
        BeforeEach {
            Mock Get-WslStatus { [pscustomobject]@{ WSL = '2.4.13' } }
        }

        It 'uses Distribution from pipeline property-name binding when Distribution is omitted' {
            Mock Get-WslDistribution { [pscustomobject]@{ Distribution = 'Ubuntu'; Status = 'Running'; IsDefault = $true } }
            Mock Invoke-WslCmdWrapper { @('', "hello", 0) }

            $Result = [pscustomobject]@{ Distribution = 'Ubuntu' } | Invoke-WslCommand -Command 'echo hello'

            $Result | Should -Be 'hello'
            Assert-MockCalled Get-WslDistribution -Times 1 -Exactly -ParameterFilter { $Distribution -eq 'Ubuntu' }
        }

        It 'throws structured error when wrapper returns non-zero exit code' {
            Mock Get-WslDistribution { [pscustomobject]@{ Distribution = 'Ubuntu'; Status = 'Running'; IsDefault = $true } }
            Mock Invoke-WslCmdWrapper { @('/bin/sh: 1: badcmd: not found', '', 127) }

            try {
                Invoke-WslCommand -Distribution 'Ubuntu' -Command 'badcmd' -ErrorAction Stop
                throw 'Expected exception was not thrown.'
            }
            catch {
                $_.FullyQualifiedErrorId | Should -Be 'PowerShellWSLCommandFailed'
                $_.Exception.Message | Should -Be '/bin/sh: 1: badcmd: not found'
                $_.Exception.Data['Distribution'] | Should -Be 'Ubuntu'
                $_.Exception.Data['ExitCode'] | Should -Be 127
                $_.Exception.Data['StdErr'] | Should -Match 'badcmd'
            }
        }
    }
}
