#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures virtual DVD drive settings

.DESCRIPTION
    Updates the configuration of a virtual DVD drive for a Microsoft Hyper-V virtual machine, including media path (ISO) and controller location.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Path
    Optional. Specifies the path to an ISO file to mount. If empty, the drive is cleared.

.PARAMETER ControllerType
    Optional. Specifies the controller type (SCSI or IDE). Defaults to SCSI.

.PARAMETER ControllerNumber
    Optional. Specifies the controller number. Defaults to 0.

.PARAMETER ControllerLocation
    Optional. Specifies the location on the controller. Defaults to 0.

.EXAMPLE
    PS> ./Set-HyperVVMDvdDrive.ps1 -Name "OS-Install" -Path "D:\ISOs\WinSRV2022.iso"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Path,

    [ValidateSet('SCSI', 'IDE')]
    [string]$ControllerType = "SCSI",

    [int]$ControllerNumber = 0,

    [int]$ControllerLocation = 0
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

        $dvdDrive = Get-VMDvdDrive -VM $vm | Where-Object { 
            $_.ControllerType -eq $ControllerType -and 
            $_.ControllerNumber -eq $ControllerNumber -and 
            $_.ControllerLocation -eq $ControllerLocation 
        }

        if (-not $dvdDrive) {
            throw "No DVD drive found on $ControllerType controller $ControllerNumber at location $ControllerLocation for VM '$Name'."
        }

        $setParams = @{ 'VMDvdDrive' = $dvdDrive; 'ErrorAction' = 'Stop' }
        if ($Path) { $setParams.Add('Path', $Path) }
        else { $setParams.Add('Path', $null) } # Eject

        Set-VMDvdDrive @setParams

        $updatedDrive = Get-VMDvdDrive -VM $vm | Where-Object { 
            $_.ControllerType -eq $ControllerType -and 
            $_.ControllerNumber -eq $ControllerNumber -and 
            $_.ControllerLocation -eq $ControllerLocation 
        }

        $result = [PSCustomObject]@{
            VMName             = $vm.Name
            ControllerType     = $updatedDrive.ControllerType
            ControllerNumber   = $updatedDrive.ControllerNumber
            ControllerLocation = $updatedDrive.ControllerLocation
            MediaPath          = $updatedDrive.Path
            Action             = "DvdDriveConfigUpdated"
            Status             = "Success"
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
