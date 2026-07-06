function Remove-ChoicedPsArgs {
 [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Collections.Generic.KeyValuePair[string, object]]$InputArgouments,

        [Parameter(Mandatory = $false)]
        [string[]]$ArgToRemove
    )

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