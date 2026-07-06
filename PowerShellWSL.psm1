# import enums
Get-ChildItem "$PSScriptRoot\Enums" -Filter *.ps1 | ForEach-Object { . $_.FullName }

# import classes
Get-ChildItem "$PSScriptRoot\Classes" -Filter *.ps1 | ForEach-Object { . $_.FullName }

# import public functions
Get-ChildItem "$PSScriptRoot\Public" -Filter *.ps1 | ForEach-Object { . $_.FullName }

# import private functions
Get-ChildItem "$PSScriptRoot\Private" -Filter *.ps1 | ForEach-Object { . $_.FullName }

# aliases setup
Set-Alias -Name 'Start-Wsl' -Value 'Start-WslDistribution' -Description "Alias for Start-WslDistribution. Starts a specified WSL distribution." 
Set-Alias -Name 'Invoke-Wsl' -Value 'Invoke-WslCommand' -Description "Alias for Invoke-WslCommand. Invokes a command in a specified WSL distribution."

Export-ModuleMember -Function (Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Recurse | ForEach-Object { $_.BaseName })`
                    -Alias 'Start-Wsl','Invoke-Wsl'