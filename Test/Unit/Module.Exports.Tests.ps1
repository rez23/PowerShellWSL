Describe 'Module Exports' -Tag Unit {
    BeforeAll {
        . "$PSScriptRoot\..\TestSetup.ps1"
    }

    $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

    It 'exports all functions declared in manifest' {
        $Manifest = Import-PowerShellDataFile (Join-Path $RepoRoot 'PowerShellWSL.psd1')
        $Exported = (Get-Command -Module PowerShellWSL).Name

        foreach ($Fn in $Manifest.FunctionsToExport) {
            $Exported | Should -Contain $Fn
        }
    }

    It 'exports Start-Wsl alias' {
        $Alias = Get-Alias -Name Start-Wsl -ErrorAction Stop
        $Alias.Definition | Should -Be 'Start-WslDistribution'
    }
}
