#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Removes a virtual DVD drive from a virtual machine

.DESCRIPTION
    Deletes a specified virtual optical drive (DVD drive) from a Microsoft Hyper-V virtual machine based on controller location.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER ControllerNumber
    Specifies the controller number.

.PARAMETER ControllerLocation
    Specifies the location on the controller.

.EXAMPLE
    PS> ./Remove-HyperVVMDvdDrive.ps1 -Name "AppSrv" -ControllerNumber 1 -ControllerLocation 0

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $true)]
    [int]$ControllerNumber,

    [Parameter(Mandatory = $true)]
    [int]$ControllerLocation
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
            $_.ControllerNumber -eq $ControllerNumber -and 
            $_.ControllerLocation -eq $ControllerLocation 
        }

        if (-not $dvdDrive) {
            throw "No DVD drive found on controller $ControllerNumber at location $ControllerLocation for VM '$Name'."
        }

        Remove-VMDvdDrive -VMDvdDrive $dvdDrive -ErrorAction Stop

        $result = [PSCustomObject]@{
            VMName             = $vm.Name
            ControllerNumber   = $ControllerNumber
            ControllerLocation = $ControllerLocation
            Action             = "DvdDriveRemoved"
            Status             = "Success"
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
