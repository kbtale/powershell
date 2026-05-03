#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves the size of virtual hard disks for virtual machines

.DESCRIPTION
    Gets the capacity and current file size of all virtual hard disks (VHD/VHDX) attached to specified virtual machines.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER VMName
    Specifies an array of virtual machine names to audit.

.EXAMPLE
    PS> ./Get-HyperVVMVHDSize.ps1 -VMName "DB-01", "DB-02"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string[]]$VMName
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $results = @()
        foreach ($vmItem in $VMName) {
            $vm = Get-VM @params | Where-Object { $_.Name -eq $vmItem -or $_.Id -eq $vmItem }
            
            if ($vm) {
                $hardDrives = Get-VMHardDiskDrive -VM $vm -ErrorAction Stop
                
                foreach ($drive in $hardDrives) {
                    if ($drive.Path) {
                        $vhd = Get-VHD -ComputerName $ComputerName -Path $drive.Path -ErrorAction Stop
                        $results += [PSCustomObject]@{
                            VMName       = $vm.Name
                            DrivePath    = $drive.Path
                            Capacity     = $vhd.Size
                            FileSize     = $vhd.FileSize
                            VhdType      = $vhd.VhdType
                            VhdFormat    = $vhd.VhdFormat
                            ComputerName = $ComputerName
                        }
                    }
                }
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
