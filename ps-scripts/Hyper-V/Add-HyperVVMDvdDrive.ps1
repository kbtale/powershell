#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Adds a virtual DVD drive to a virtual machine

.DESCRIPTION
    Provisions a new virtual optical drive (DVD drive) for a Microsoft Hyper-V virtual machine on a specified controller.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER ControllerType
    Optional. Specifies the controller type (SCSI or IDE). Defaults to SCSI.

.PARAMETER ControllerNumber
    Optional. Specifies the controller number. Defaults to 0.

.PARAMETER Path
    Optional. Specifies the path to an ISO file to mount upon creation.

.EXAMPLE
    PS> ./Add-HyperVVMDvdDrive.ps1 -Name "OS-Install" -Path "D:\ISOs\WinSRV2022.iso"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('SCSI', 'IDE')]
    [string]$ControllerType = "SCSI",

    [int]$ControllerNumber = 0,

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

        $addParams = @{ 'VM' = $vm; 'ControllerType' = $ControllerType; 'ControllerNumber' = $ControllerNumber; 'ErrorAction' = 'Stop' }
        if ($Path) { $addParams.Add('Path', $Path) }

        Add-VMDvdDrive @addParams

        $dvdDrives = Get-VMDvdDrive -VM $vm | Where-Object { $_.ControllerType -eq $ControllerType -and $_.ControllerNumber -eq $ControllerNumber }
        
        $result = [PSCustomObject]@{
            VMName           = $vm.Name
            ControllerType   = $ControllerType
            ControllerNumber = $ControllerNumber
            DvdDriveCount    = $dvdDrives.Count
            Action           = "DvdDriveAdded"
            Status           = "Success"
            Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
