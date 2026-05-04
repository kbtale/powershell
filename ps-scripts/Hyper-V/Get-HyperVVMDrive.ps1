#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine storage drives

.DESCRIPTION
    Retrieves detailed information about all storage drives (Hard Disks, DVD drives, and Floppy drives) attached to a Microsoft Hyper-V virtual machine.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER Type
    Optional. Filters by drive type (HardDisk, DVD, Floppy, or All). Defaults to All.

.EXAMPLE
    PS> ./Get-HyperVVMDrive.ps1 -Name "AppSrv" -Type HardDisk

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [ValidateSet('HardDisk', 'DVD', 'Floppy', 'All')]
    [string]$Type = "All"
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

        $results = New-Object System.Collections.Generic.List[PSObject]

        if ($Type -match 'All|HardDisk') {
            Get-VMHardDiskDrive -VM $vm | ForEach-Object {
                $results.Add([PSCustomObject]@{
                    VMName             = $vm.Name
                    Type               = "HardDisk"
                    Name               = $_.Name
                    Path               = $_.Path
                    ControllerType     = $_.ControllerType
                    ControllerNumber   = $_.ControllerNumber
                    ControllerLocation = $_.ControllerLocation
                    Status             = $_.Status
                })
            }
        }

        if ($Type -match 'All|DVD') {
            Get-VMDvdDrive -VM $vm | ForEach-Object {
                $results.Add([PSCustomObject]@{
                    VMName             = $vm.Name
                    Type               = "DVD"
                    Name               = $_.Name
                    Path               = $_.Path
                    ControllerType     = $_.ControllerType
                    ControllerNumber   = $_.ControllerNumber
                    ControllerLocation = $_.ControllerLocation
                    Status             = "N/A"
                })
            }
        }

        if ($Type -match 'All|Floppy' -and $vm.Generation -eq 1) {
            Get-VMFloppyDiskDrive -VM $vm | ForEach-Object {
                $results.Add([PSCustomObject]@{
                    VMName             = $vm.Name
                    Type               = "Floppy"
                    Name               = $_.Name
                    Path               = $_.Path
                    ControllerType     = "Floppy"
                    ControllerNumber   = 0
                    ControllerLocation = 0
                    Status             = "N/A"
                })
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
