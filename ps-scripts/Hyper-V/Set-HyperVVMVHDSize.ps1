#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Resizes a virtual machine virtual hard disk

.DESCRIPTION
    Updates the size of a specifies Microsoft Hyper-V virtual hard disk (VHD/VHDX). Supports resizing to a specifies size or to the minimum possible size based on internal volume usage.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER ControllerType
    Specifies the controller type (SCSI or IDE).

.PARAMETER ControllerNumber
    Specifies the controller number.

.PARAMETER ControllerLocation
    Specifies the location on the controller.

.PARAMETER SizeBytes
    Optional. Specifies the new size in bytes (e.g., 100GB, 1TB).

.PARAMETER ToMinimumSize
    Optional. If set, resizes the disk to its minimum possible size.

.EXAMPLE
    PS> ./Set-HyperVVMVHDSize.ps1 -Name "AppSrv" -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -SizeBytes 200GB

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [ValidateSet('SCSI', 'IDE')]
    [string]$ControllerType,

    [int]$ControllerNumber = 0,

    [int]$ControllerLocation = 0,

    [uint64]$SizeBytes,

    [switch]$ToMinimumSize
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

        $drive = Get-VMHardDiskDrive -VM $vm | Where-Object { 
            $_.ControllerType -eq $ControllerType -and 
            $_.ControllerNumber -eq $ControllerNumber -and 
            $_.ControllerLocation -eq $ControllerLocation 
        }

        if (-not $drive) {
            throw "No hard disk drive found on $ControllerType controller $ControllerNumber at location $ControllerLocation for VM '$Name'."
        }

        $resizeParams = @{ 'Path' = $drive.Path; 'ErrorAction' = 'Stop' }
        if ($Credential) { $resizeParams.Add('Credential', $Credential) }
        else { $resizeParams.Add('ComputerName', $ComputerName) }

        if ($ToMinimumSize) {
            Resize-VHD @resizeParams -ToMinimumSize
        }
        elseif ($SizeBytes) {
            Resize-VHD @resizeParams -SizeBytes $SizeBytes
        }
        else {
            throw "Either -SizeBytes or -ToMinimumSize must be specified."
        }

        $updatedVHD = Get-VHD @resizeParams
        
        $result = [PSCustomObject]@{
            VMName             = $vm.Name
            VHDPath            = $drive.Path
            ControllerType     = $ControllerType
            ControllerNumber   = $ControllerNumber
            ControllerLocation = $ControllerLocation
            NewSize            = $updatedVHD.Size
            MinimumSize        = $updatedVHD.MinimumSize
            Action             = "VHDResized"
            Status             = "Success"
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
