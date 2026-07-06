<#
.SYNOPSIS
    Gets the WSL version and related information.
.DESCRIPTION
    Gets the WSL version and related information.
    This function is a wrapper for the 'wsl -v' command.
    It retrieves the WSL version, kernel version, and other relevant details.
.EXAMPLE
    # Get WSL default distribution and kernel version
    Get-WslStatus | Select-Object -Property MainDistro, Kernel
.NOTES
    Requires WSL to be installed. Ensure you have the necessary permissions to perform this operation.
.COMPONENT
    Windows Subsystem for Linux (WSL)
#>
function Get-WslStatus {
    $StdErr, $WslOut, $Res = Invoke-WslCmdWrapper -WslArgs @('-v') -ErrorAction Stop

    if ($Res -ne 0) {
        throw (New-WslErrorRecord @{
            Message      = "Failed to get WSL status with message: '$StdErr'"
            ErrorId      = "PowerShellWSLStatusQueryFailed"
            Distribution = $null
            WslArgs      = "-v"
            ExitCode     = $Res
            StdErr       = ($StdErr | Out-String).Trim()
            WslVersion   = $null
        })
    }
    $Values = $WslOut -split "`n" | ConvertTo-CleanedWslString | ForEach-Object {
        ($_ -split ":")[1]
    } | ForEach-Object {
        if ([string]::IsNullOrEmpty($_) -or [string]::IsNullOrWhiteSpace($_)) {
            return
        }
        else {
            $_
        }
    }

    $PropsName  =@(
        'WSL'      
        'Kernel'   
        'WSLg'     
        'MSRDC'    
        'Direct3D'
        'DXCore'   
        'Windows'
    )
    
    $Serialized = @{
        MainDistro = Get-WslDistribution -Default
    }
    $PropsName | ForEach-Object -Begin {$ValueIdx = 0} -Process {
        $PropertyName = $_
        $PropertyValue = $Values[$ValueIdx]
        $Serialized[$PropertyName] = Convert-FromStringToWSLVersion $PropertyValue
        $ValueIdx++
    }

    # return the serialized object as a PSCustomObject reordering the properties to match the desired output
    [pscustomobject]$Serialized | Select-Object -Property MainDistro, Kernel, WSL, WSLg, MSRDC, Direct3D, DXCore, Windows
}