class WslDistribution {
    [string]$Distribution
    [string]$Version
    [string]$VhdFile
    [WslDistributionStatus]$Status
    [bool] $IsDefault

    WslDistribution([string]$Distribution, [string]$Version, [bool]$IsDefault, [WslDistributionStatus]$Status, [string]$VhdFile) {
        $this.Distribution = $Distribution
        $this.Version = $Version
        $this.IsDefault = $IsDefault
        $this.Status = $Status
        $this.VhdFile = $VhdFile
    }

    WslDistribution([pscustomobject]$DistroObject) {
        $this.Distribution = $DistroObject.Distribution
        $this.Version = $DistroObject.Version
        $this.IsDefault = $DistroObject.IsDefault
        $this.Status = $DistroObject.Status
        $this.VhdFile = $DistroObject.VhdFile
    }

    [string] ToString() {
        return "$($this.Distribution) (v$($this.Version) $($this.Status))"
    }
}