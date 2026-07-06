<#
.SYNOPSIS
    Serializes the output of a WSL command into a PowerShell object.
.DESCRIPTION
    This function takes the output of a WSL command and serializes it into a PowerShell object. It allows for customization of the serialization process, including specifying delimiters, columns, rows, and property names. The function can handle multiple results and provides options for trimming and cleaning the output.
.PARAMETER WslResult
    The output of a WSL command to be serialized.
.PARAMETER Delimiter
    Optional. The delimiter used to split the output into columns. Default is ":".
.PARAMETER Column
    Optional. The column index to extract from the split output. Default is 0.
.PARAMETER Row
    Optional. The row index to extract from the output. Default is 0.
.PARAMETER NToTrimOnStart
    Optional. The number of characters to trim from the start of the output. Default is 0.
.PARAMETER NToTrimOnEnd
    Optional. The number of characters to trim from the end of the output. Default is 0.
.PARAMETER TrimExpression
    Optional. A regex expression to trim from the output.
.PARAMETER PropertyNames
    Optional. An array of property names to assign to the serialized object.
.PARAMETER MultipleResults
    Optional. A switch to indicate if multiple results are expected.
#>
function Get-WslCmdOutputSerialized {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]]$WslResult,
        [Parameter(Mandatory = $false)]
        [string]$Delimiter = ":",
        [Parameter(Mandatory = $false)]
        [int]$Column = 0,
        [Parameter(Mandatory = $false)]
        [int]$Row = 0,
        [Parameter(Mandatory = $false)]
        [int]$NToTrimOnStart = 0,
        [Parameter(Mandatory = $false)]
        [int]$NToTrimOnEnd = 0,
        [Parameter(Mandatory = $false)]
        [string]$TrimExpression,
        [Parameter(Mandatory = $false)]
        [string[]]$PropertyNames,
        [Parameter(Mandatory = $false)]
        [switch]$MultipleResults,
        [Parameter(Mandatory = $false)]
        [int]$RowLimit = 0,
        [Parameter(Mandatory = $false)]
        [int]$ColumnPos = 1,
        [Parameter(Mandatory = $false)]
        [int]$ObjetDept = 0,
        [Parameter(Mandatory = $false)]
        [switch]$NoSplit
    )
    $ObjectResult = $WslResult | 
    ForEach-Object -Begin { $PropertyIdx = 0 } -Process {
        $Value = if ($NoSplit) { $_ } else { ($_ -split $Delimiter)[$ColumnPos] }
        if (([string]::IsNullOrEmpty($Value)) -or ([string]::IsNullOrWhiteSpace($Value))) {
            return
        }
        $Key = $PropertyNames[$PropertyIdx]
        $PropertyIdx++
        Write-Verbose "Processed property: $Key with value: <$Value>"
        [pscustomobject]@{
            Key   = & $Script:CleanWSLString $Key.Trim()
            Value = & $Script:CleanWSLString $Value.Trim()
        }
    }

    $Serialized = @{}
    $ObjectResult | Foreach-Object {
        Write-Verbose "$($_.Key) = $($_.Value)"
        $Serialized[($_.Key -replace '\s', '')] = ($_.Value -replace '\s', '')
    }
    
    [pscustomobject]$Serialized
}