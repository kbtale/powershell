#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual hard disk storage details and controller paths

.DESCRIPTION
    Retrieves detailed storage metrics for all virtual hard disks (VHD/VHDX) attached to a specifies Microsoft Hyper-V virtual machine, including physical file size, maximum capacity, and controller pathing.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMVHDDetail.ps1 -Name "Database-Srv"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name
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

        $vhdDrives = Get-VMHardDiskDrive -VM $vm -ErrorAction Stop
        
        $results = foreach ($drive in $vhdDrives) {
            $vhd = Get-VHD -ComputerName $ComputerName -Path $drive.Path -ErrorAction Stop
            
            [PSCustomObject]@{
                VMName           = $vm.Name
                ControllerType   = $drive.ControllerType
                ControllerNumber = $drive.ControllerNumber
                ControllerLocation = $drive.ControllerLocation
                Path             = $drive.Path
                VhdType          = $vhd.VhdType
                VhdFormat        = $vhd.VhdFormat
                FileSizeGB       = [math]::Round($vhd.FileSize / 1GB, 2)
                SizeGB           = [math]::Round($vhd.Size / 1GB, 2)
                Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
