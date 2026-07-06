param(
    [switch]$NoLinks,
    [switch]$OnlySubject
)

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

# Generate a changelog from the git history of the current repository.
function Get-GitChangelog {
    $repoUrl = git remote get-url origin

    $repoUrl = $repoUrl `
        -replace '^git@github.com:', 'https://github.com/' `
        -replace '\.git$', ''

    $tags = git tag --sort=-version:refname

    $currentTag = $tags[0]
    $previousTag = $tags[1]

    (git log "$previousTag..$currentTag" --pretty=format:"%H|%h|%s").Trim() | ConvertTo-CleanedWslString | ForEach-Object {
        $hash, $shortHash, $subject = ($_ -split '\|')

        if ($NoLinks) {
            "- $shortHash $subject"
        } elseif ($OnlySubject) {
            "- $subject"
        } else {
            "- [$shortHash]($repoUrl/commit/$hash) $subject"
        }
    }
    ForEach-Object {

        $hash, $shortHash, $subject = ($_ -split "`|",3)
        if ([string]::IsNullOrWhiteSpace($subject)) {
            return
        }

        if ($NoLinks) {
            "- $shortHash $subject"
        } elseif ($OnlySubject) {
            "- $subject"
        } else {
            "- [$shortHash]($repoUrl/commit/$hash) $subject"
        }
    }
}

Get-GitChangelog