#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Deletes a virtual machine

.DESCRIPTION
    Removes a specified Microsoft Hyper-V virtual machine from the host.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine to delete.

.PARAMETER Force
    If set, deletes the virtual machine without confirmation.

.EXAMPLE
    PS> ./Remove-HyperVVM.ps1 -Name "Test-VM-01" -Force

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [switch]$Force
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

        Remove-VM -VM $vm -Force:$Force -Confirm:(-not $Force) -ErrorAction Stop

        $result = [PSCustomObject]@{
            Name         = $Name
            Action       = "VirtualMachineDeleted"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
