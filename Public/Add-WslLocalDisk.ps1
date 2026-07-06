<#
.SYNOPSIS
    Mounts a local device in a WSL distribution.
.DESCRIPTION
    This function mounts a specified local device (e.g., a physical disk or a VHD file) in a given Windows Subsystem for Linux (WSL) distribution. It allows you to specify the distribution, the device to mount, the filesystem type, mount options, and whether to mount a specific partition or the entire device.
.PARAMETER Disk
    The path to the local device to mount (e.g., "\\.\PHYSICALDRIVE1" for a physical disk or "C:\path\to\disk.vhdx" for a VHD file).
.PARAMETER FsType
    Optional. The filesystem type to use for mounting the device (e.g., "ext4", "ntfs"). If not specified, WSL will attempt to auto-detect the filesystem type.
.PARAMETER Options
    Optional. Additional mount options to pass to the mount command (e.g., "ro" for read-only). This can be a comma-separated list of options.
.PARAMETER PartitionIdx
    Optional. The index of the partition to mount on the device. If not specified, the entire device will be mounted.
.PARAMETER Bare
    Optional. A switch to indicate that the device should be mounted without any additional options or configurations
.PARAMETER Vhd
    Optional. A switch to indicate that the device being mounted is a VHD file. This
    will ensure that WSL treats the device as a virtual disk and handles it accordingly.
.COMPONENT
    Windows Subsystem for Linux (WSL)
.NOTES
    Requires WSL to be installed and the specified distribution to be running. Ensure you have the
    necessary permissions to perform this operation, especially when mounting physical disks or VHD files.
#>
function Add-WslLocalDisk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
                (Get-CimInstance Win32_DiskDrive | Where-Object { $_.DeviceID -eq $_ }).Count -lt 1
            })]
        [ArgumentCompleter({ 
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters) 
                
                # Get the list of disk drives from the system and filter based on the user's input
                Get-CimInstance Win32_DiskDrive |  Where-Object { $_.DeviceID -like "$wordToComplete*" } | ForEach-Object { $_.DeviceID }
            })]
        $Disk,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        # Custom completion logic for filesystem types based on WSL output 
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

                $DistributionName = $fakeBoundParameters['Distribution']
                if (-not $DistributionName) {
                    $DistributionName = Get-WslDistribution -Default | Select-Object -ExpandProperty Distribution
                }

                # Get the list of supported filesystem types from the specified WSL distribution
                $SupportedFsTypes = (Invoke-WslCommand -System -Command "cat /proc/filesystems | awk '!/nodev/ {print `$1}'") -split "`n" | ForEach-Object { $_.Trim() }
                $SupportedFsTypes | Where-Object { $_ -like "$wordToComplete*" }
            })]
        [string]$FsType,
        [Parameter(Mandatory = $false)]
        [string]$Options,
        [Parameter(Mandatory = $false)]
        [ArgumentCompleter({
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

                $CurrentDisk = $fakeBoundParameters['Disk']
                if (-not $CurrentDisk) {
                    return
                }

                # Get the list of partitions for the specified disk                
                Get-Partition -DiskNumber ($CurrentDisk -replace "\\\\\.\\PHYSICALDRIVE", "") -ErrorAction SilentlyContinue | 
                Select-Object -ExpandProperty PartitionNumber | 
                Where-Object { $_ -like "$wordToComplete*" }
            })]
        [int]$PartitionIdx,
        [Parameter(Mandatory = $false)]
        [switch]$Bare,
        [Parameter(Mandatory = $false)]
        [switch]$Vhd
    )

    process {
        $LegacyArgs = $PSBoundParameters.GetEnumerator() | ForEach-Object {
            if ($_.Key -eq "FsType") {
                @{ Key = "Type"; Value = $_.Value.ToString() }
            }
            elseif ($_.Key -eq "PartitionIdx") {
                @{ Key = "Partition"; Value = $_.Value }
            }
            else {
                $_
            }
        }
    
        # get argsoument normalized to WSL command line format
        $WslArgs = $LegacyArgs |  
        Remove-StdPsArgsFromWslArgs -ArgToRemove @("Distribution", "Disk") | 
        Convert-PsArgsToWsl

        # Check if the distribution is running
        $CurrentDistro = Get-WslDistribution -Distribution $Distribution -ErrorAction SilentlyContinue
        if (-not $CurrentDistro) {
            throw (New-WslErrorRecord @{
                    Message      = "WSL distribution not found."
                    ErrorId      = "PowerShellWSLDistributionNotFound"
                    Distribution = $Distribution
                    WslArgs      = ($WslArgs -join ' ')
                    ExitCode     = $null
                    StdErr       = $null
                    WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }

        # Mount the virtual file system
        Write-Information "Mounting WSL virtual file system for distribution '$Distribution' at '$MountPoint'..."
        $StdErr, $StdOut, $Res = Invoke-WslCmdWrapper -WslArgs @('--mount', $Disk, $WslArgs) -ErrorAction Stop
        if ($Res -ne 0) {
            throw (New-WslErrorRecord @{
                    Message      = "Failed to mount local disk in WSL with message: '$StdErr'"
                    ErrorId      = "PowerShellWSLMountDiskFailed"
                    Distribution = $Distribution
                    WslArgs      = @('--mount', $Disk, $WslArgs) -join ' '
                    ExitCode     = $Res
                    StdErr       = ($StdErr | Out-String).Trim()
                    WslVersion   = (Get-WslStatus -ErrorAction SilentlyContinue).WSL
                })
        }
        else {
            Write-Information "Successfully mounted WSL for distribution '$Distribution'."
        }
    }
}