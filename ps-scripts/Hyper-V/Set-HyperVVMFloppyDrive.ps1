#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures virtual floppy drive settings

.DESCRIPTION
    Updates the configuration of a virtual floppy drive for a Microsoft Hyper-V Generation 1 virtual machine, including media path (.vfd).

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Path
    Optional. Specifies the path to a virtual floppy disk file (.vfd) to mount. If empty, the drive is cleared.

.EXAMPLE
    PS> ./Set-HyperVVMFloppyDrive.ps1 -Name "OldOS" -Path "D:\Floppies\Boot.vfd"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Path
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $vm = Get-VM @params | Where-Object { $_.Name -eq $Name -or $_.Id -eq $Name }

        if (-not $vm) {
            throw "Virtual machine '$Name' not found on '$ComputerName'."
        }

        if ($vm.Generation -ne 1) {
            throw "Virtual machine '$Name' is Generation $($vm.Generation). Floppy drives only apply to Generation 1."
        }

        $floppyParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        if ($Path) { $floppyParams.Add('Path', $Path) }
        else { $floppyParams.Add('Path', $null) } # Eject

        Set-VMFloppyDiskDrive @floppyParams

        $updatedDrive = Get-VMFloppyDiskDrive -VM $vm
        
        $result = [PSCustomObject]@{
            VMName    = $vm.Name
            MediaPath = $updatedDrive.Path
            Action    = "FloppyDriveConfigUpdated"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
