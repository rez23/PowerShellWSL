<#
.SYNOPSIS
    Represents the status of a WSL distribution.
.DESCRIPTION
    This enum defines the possible states of a Windows Subsystem for Linux (WSL) distribution.
#>
enum WslDistributionStatus {
    Unknown
    Stopped
    Running
    Installing
    Uninstalling
}