function ConvertTo-Kebab {
    param([string]$InputString, [bool]$ToLower=$true)
    $kebab = $InputString `
        -creplace '([a-z0-9])([A-Z])', '$1-$2' `
        -creplace '([A-Z]+)([A-Z][a-z])', '$1-$2'
    if ($ToLower) {
        $kebab = $kebab.ToLowerInvariant()
    }
    return $kebab
}