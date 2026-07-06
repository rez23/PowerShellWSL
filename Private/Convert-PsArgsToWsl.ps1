function Convert-PsArgsToWsl {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Collections.Generic.KeyValuePair[string, object]]$InputArgouments
    )

    process {
        if ($null -eq $_.Value) {
            return
        }

        $ParamName = "--$(ConvertTo-Kebab -InputString $_.Key)"

        # Convert the value to string
        $Value = if ($_.Key -eq "ShellType") { 
            # lowercase the ShellType parameter for WSL command
            $_.Value.ToLower()
        } else { 
            $_.Value 
        }

        if ($Value -is [System.Management.Automation.SwitchParameter]) {
            if ($Value.IsPresent) {
                $ParamName
            }
        } else {
            [string]$ParamName
            [string]$Value
        }
    }
}