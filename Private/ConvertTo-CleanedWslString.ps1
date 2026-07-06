<#
.SYNOPSIS
    Cleans a WSL string by removing unwanted characters.
.DESCRIPTION
    This function takes a string and removes ANSI escape sequences, control characters, zero-width spaces, non-breaking spaces, tabs, and extra whitespace. It returns a cleaned version of the string.
.PARAMETER s
    The string to clean.
#>
function ConvertTo-CleanedWslString {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)][string]$s)
    process {
    $s -replace '\x1B\[[0-9;]*[A-Za-z]', '' `
        -replace '[\x00-\x1F]', '' `
        -replace '\u200B', '' `
        -replace '\u00A0', ' ' `
        -replace '\t', ' ' `
        -replace '\s+', ' ' `
    | ForEach-Object { $_.Trim() }
    }
}