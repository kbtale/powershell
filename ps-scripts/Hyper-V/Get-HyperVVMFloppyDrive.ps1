#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine floppy drive attachments

.DESCRIPTION
    Retrieves information for virtual floppy disk drives on a Microsoft Hyper-V virtual machine, typically used on Generation 1 VMs for driver or configuration injection.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMFloppyDrive.ps1 -Name "Legacy-OS"

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

        $floppyDrives = Get-VMFloppyDiskDrive -VM $vm -ErrorAction Stop
        
        $results = foreach ($floppy in $floppyDrives) {
            [PSCustomObject]@{
                VMName     = $vm.Name
                Path       = $floppy.Path
                IsAttached = [bool]$floppy.Path
                Generation = $vm.Generation
                Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
