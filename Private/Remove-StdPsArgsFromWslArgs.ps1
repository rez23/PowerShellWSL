$Script:common51 = @(
    'Verbose', 'Debug',
    'ErrorAction', 'WarningAction', 'InformationAction',
    'ErrorVariable', 'WarningVariable', 'InformationVariable',
    'OutVariable', 'OutBuffer', 'PipelineVariable',
    'WhatIf', 'Confirm'
)

function Remove-StdPsArgsFromWslArgs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Collections.Generic.KeyValuePair[string, object]]$InputArgouments,

        [Parameter(Mandatory = $false)]
        [string[]]$ArgToRemove
    )

    begin {
        if (-not $ArgToRemove) {
            $ArgToRemove = $Script:common51
        }
        else {
            $ArgToRemove += $Script:common51 + $ArgToRemove
        }
    }
    process { 
        $res = $ArgToRemove -contains $_.Key
        if ($res) {
            Write-Verbose "'-$($_.Key)' removed from WSL command arguments list."
        }
        else {
            $_
        }
    } 
}