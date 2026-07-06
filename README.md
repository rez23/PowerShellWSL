# PowerShellWSL a PowerShell wrapper to WSL

PowerShell module to manage in the most complete ways Windows Subsystem for Linux  via PowerShells.

## Installation

```powershell
Set-PSResourceRepository -Name PSGallery -Trusted
Install-PsResource -Name PowerShellWSL -Scope CurrentUser
Import-Module PowerShellWSL
```

## Exported Commands

### Core WSL Management

- `Get-WslStatus`: Shows WSL platform status and version details.
- `Get-WslDistribution`: Lists installed distributions and supports filtering by status/default/name pattern.
- `Find-WslDistribution`: Lists installable distributions from `wsl --list --online`.
- `Install-WslDistribution`: Installs a distribution from Store or local source.
- `Unregister-WslDistribution`: Unregisters one or more distributions.
- `Start-WslDistribution` (alias `Start-Wsl`): Starts a specific distribution.
- `Stop-WslDistribution`: Stops a specific distribution.
- `Stop-Wsl`: Shuts down the full WSL service (`wsl --shutdown`).
- `Set-Wsl`: Placeholder for future defaults management (currently warns that it is not implemented).

### Command Execution and Config

- `Invoke-WslCommand`: Runs commands inside WSL with optional distro/user/shell controls.
- `Get-WslConfig`: Reads global `.wslconfig` or distro `/etc/wsl.conf`.
- `ConvertTo-WslPath`: Converts Windows paths to WSL paths.
- `ConvertTo-WindowsPath`: Converts WSL paths to Windows paths.

### VHD and Storage Helpers

- `Export-WslVhdToFile`: Exports a distribution to archive/image formats.
- `Import-WslVhdFromFile`: Imports/registers a distribution from VHD or tar.
- `Get-WslVirtualDrivePaths`: Returns WSL and/or Docker VHD paths.
- `Optimize-WslVirtualDrives`: Optimizes WSL/Docker virtual drives to reclaim space.
- `Add-WslLocalDisk`: Mounts local disks/VHDs into WSL.
- `Remove-WslLocalDisk`: Unmounts local disks from WSL.

## Usage Examples

Note: many management/action cmdlets return no pipeline objects on success.
To see progress/success messages, use `-InformationAction Continue`.

### 1) Inspect WSL status and installed distros

```powershell
Get-WslStatus
```
```stdout
MainDistro : Ubuntu (v2 Stopped)
Kernel     : 6.6.114.1
WSL        : 2.7.3.0
WSLg       : 1.0.73.0
MSRDC      : 1.2.6676.0
Direct3D   : 1.611.1.0
DXCore     : 10.0.26100.1
Windows    : 10.0.26200.8737
```

```powershell
Get-WslDistribution
```
```stdout
Distribution   Version IsDefault  Status
------------   ------- ---------  ------
Ubuntu         2            True Stopped
docker-desktop 2           False Stopped
archlinux      2           False Stopped
```

```powershell
Get-WslDistribution -Default
```
```stdout
Distribution Version IsDefault  Status
------------ ------- ---------  ------
Ubuntu       2            True Stopped
```

```powershell
Get-WslDistribution -Distribution "Ubuntu*"
```
```stdout
Distribution Version IsDefault  Status
------------ ------- ---------  ------
Ubuntu       2            True Stopped
```

```powershell
Get-WslDistribution -Status Running
```
```stdout

```

### 2) Discover installable distros from online catalog

```powershell
Find-WslDistribution -Distribution "Ubuntu*"
```
```stdout
Distribution FriendlyName     IsInstalled
------------ ------------     -----------
Ubuntu       Ubuntu                  True
Ubuntu-26.04 Ubuntu 26.04 LTS       False
Ubuntu-24.04 Ubuntu 24.04 LTS       False
Ubuntu-22.04 Ubuntu 22.04 LTS       False
```

### 3) Work with distributions (install, unregister, etc.)
Install a distribution from the online catalog:
```powershell
Install-WslDistribution -Distribution "Ubuntu" -InformationAction Continue
```

Install a distribution from a local tar file:
```powershell
Install-WslDistribution -FromFile "D:\Backups\ubuntu.tar" -Name "Ubuntu-Dev" -Location "D:\WSL\Ubuntu-Dev" -InformationAction Continue
```
Unregister a distribution:
```powershell
Unregister-WslDistribution -Distribution "Ubuntu-Dev" -InformationAction Continue
```

Start installed distributions:
```powershell
Start-WslDistribution -Distribution "Ubuntu" -InformationAction Continue
```
or
```powershell
Start-Wsl -Distribution "Ubuntu" -InformationAction Continue
```

Stop a running distribution:
```powershell
Stop-WslDistribution -Distribution "Ubuntu" -InformationAction Continue
```

Shutdown the full WSL service:
```powershell
Stop-Wsl -InformationAction Continue
```

### 5) Run commands inside WSL

```powershell
Invoke-WslCommand -Distribution "Ubuntu" -Command "uname -a"
```
```stdout
Linux MSI 6.6.114.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Mon Dec 1 20:46:23 UTC 2025 x86_64 GNU/Linux
```

```powershell
Get-WslDistribution -Default | Invoke-WslCommand -Command "whoami"
```
```stdout
spart
```

### 6) Read WSL configuration

Get Host `.wslconfig` values: 
```powershell
Get-WslConfig
```

Get a specific distribution's `/etc/wsl.conf` values:
```powershell
Get-WslConfig -Distribution "Ubuntu"
```
```stdout
Property      Value
---------     -----
boot.systemd  true
user.default  spart
```

### 7) Navigate paths in WSL FS (via Host)

Get item from WSL path:
```powershell
# Get items
Get-WslItem -Path /home/spart
Get-WslChildItem -Path /home/apart

# Remove items
Remove-WslItem -Path /home/spart/my-file.txt

# Add items
Add-WslItem -ItemType Directory -Path /my-dir
```

### 8) Export and import distro data

```powershell
Export-WslVhdToFile -Distribution "Ubuntu" -Destination "D:\Backups\Ubuntu-20260704.tar" -InformationAction Continue
```

```powershell
Export-WslVhdToFile -Distribution "Ubuntu" -Destination "D:\Backups\Ubuntu.vhdx" -FormatAs vhdx -InformationAction Continue
```
```text
Not executed in this verification pass (mutating command).
```

```powershell
Import-WslVhdFromFile -Distribution "Ubuntu-Restore" -InstallLocation "D:\WSL\Ubuntu-Restore" -VhdPath "D:\Backups\Ubuntu.vhdx" -InformationAction Continue
```

### 9) Inspect and optimize virtual drive files

```powershell
Get-WslVirtualDrivePaths -Wsl
```
```stdout
DockerVHDPaths
--------------
{C:\Users\spart\AppData\Local\Docker\wsl\disk\docker_data.vhdx, C:\Users\spart\AppData\Local\Docker\wsl\disk\docker_image.vhdx}
```

```powershell
Get-WslVirtualDrivePaths -Docker
```
```stdout
DockerVHDPaths
--------------
{C:\Users\spart\AppData\Local\Docker\wsl\disk\docker_data.vhdx, C:\Users\spart\AppData\Local\Docker\wsl\disk\docker_image.vhdx}
```

```powershell
Optimize-WslVirtualDrives -Wsl -InformationAction Continue
```

```powershell
Optimize-WslVirtualDrives -Docker -InformationAction Continue
```

### 10) Mount and unmount local disks in WSL

```powershell
Add-WslLocalDisk -Disk "\\.\PHYSICALDRIVE3" -FsType ext4 -InformationAction Continue
```

```powershell
Add-WslLocalDisk -Disk "D:\Disks\data.vhdx" -Vhd -FsType ext4 -InformationAction Continue
```

```powershell
Remove-WslLocalDisk -Disk "\\.\PHYSICALDRIVE3" -InformationAction Continue
```

## Notes

- Use `Get-Help <CommandName> -Detailed` for full parameter documentation.
- Commands that accept `-Distribution` support property-name pipeline binding where applicable.
- For release/tag automation, see local hooks and CI workflows in `.githooks` and `.github/workflows`.

## Support

If this project helps you, star the repository or support the author:

- [PayPal.me](https://paypal.me/rez23774)
- [Ko-Fi](https://ko-fi.com/spartacoamadei)

