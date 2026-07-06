Describe 'Get-WslDistribution' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    InModuleScope PowerShellWSL {
        BeforeEach {
            Mock Invoke-WslCmdWrapper {
                $Output = @(
                    'NAME STATE VERSION',
                    '* Ubuntu Running 2',
                    'Debian Stopped 2'
                ) -join "`n"

                @('', $Output, 0)
            }
        }

        It 'returns all distributions from parsed wsl output' {
            $Result = Get-WslDistribution

            $Result.Count | Should -Be 2
            $Result[0].Distribution | Should -Be 'Ubuntu'
            $Result[0].IsDefault | Should -BeTrue
            $Result[1].Distribution | Should -Be 'Debian'
            $Result[1].Status.ToString() | Should -Be 'Stopped'
        }

        It 'filters by Distribution' {
            $Result = Get-WslDistribution -Distribution 'Deb*'

            $Result.Count | Should -Be 1
            $Result[0].Distribution | Should -Be 'Debian'
        }

        It 'returns only default distro with -Default' {
            $Result = Get-WslDistribution -Default

            $Result.Count | Should -Be 1
            $Result[0].Distribution | Should -Be 'Ubuntu'
            $Result[0].IsDefault | Should -BeTrue
        }
    }
}
