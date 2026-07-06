<#
.SYNOPSIS
    Represents a WSL version.
.DESCRIPTION
    This class represents a WSL version and provides methods to convert a string 
    representation of a WSL version to a WSLVersion object.
    The Convert-FromStringToWSLVersion function takes a string representation of a
    WS version and returns a WSLVersion object.
#>
class WslVersion {
    [int]$Major
    [int]$Minor
    [int]$Build
    [int]$Revision

    WSLVersion([PsCustomObject]$version) {
        $this.Major = $version.Major
        $this.Minor = $version.Minor
        $this.Build = $version.Build
        $this.Revision = $version.Revision
    }
    WSLVersion([int]$major, [int]$minor, [int]$build, [int]$revision) {
        $this.Major = $major
        $this.Minor = $minor
        $this.Build = $build
        $this.Revision = $revision
    }

    [string] ToString() {
        return "$($this.Major).$($this.Minor).$($this.Build).$($this.Revision)"
    }
}
