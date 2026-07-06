<#
.SYNOPSIS
    Converts a raw WSL configuration string into a structured PowerShell object.
.DESCRIPTION
    This function takes a raw WSL configuration string, typically read from a .wslconfig
    or /etc/wsl.conf file, and converts it into a structured PowerShell object (hashtable).
    It parses the configuration into sections and key-value pairs, allowing for easier
    manipulation and access to the configuration settings.
.PARAMETER RawConfig
    The raw WSL configuration string to be converted. This should be the content of a .
    wslconfig or /etc/wsl.conf file, provided as a single string.
#>
function ConvertFrom-RawWslConfig {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$RawConfig
    )

    # Get the raw config lines, trim whitespace, and remove empty lines
    $RawConfigLines = $RawConfig -split "`r?`n" |
        ForEach-Object { ConvertTo-CleanedWslString $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    # Create a hashtable to store the parsed config
    $ParsedConfig = @{}
    $section = $null

    $RawConfigLines | ForEach-Object {
        $line = $_

        if ($line -match '^\s*\[(?<section>[^\]]+)\]\s*$') {
            $section = $matches.section.Trim()
            return
        }

        if ($line -match '^\s*(?<key>[^=;#\s][^=;#]*)\s*=\s*(?<value>.*?)\s*$') {
            $key = $matches.key.Trim()
            $value = $matches.value.Trim()
            $fullKey = if ($section) { "$section.$key" } else { $key }
            $ParsedConfig[$fullKey] = $value
        }
    }

    return $ParsedConfig
}