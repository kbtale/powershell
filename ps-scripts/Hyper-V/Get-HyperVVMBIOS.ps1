#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits Generation 1 virtual machine BIOS configuration

.DESCRIPTION
    Retrieves the BIOS configuration for a specifies Microsoft Hyper-V Generation 1 virtual machine, including boot device order and NumLock state.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMBIOS.ps1 -Name "LegacySrv-01"

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

        if ($vm.Generation -ne 1) {
            throw "BIOS configuration is only supported on Generation 1 virtual machines. VM '$Name' is Generation $($vm.Generation)."
        }

        $bios = Get-VMBios -VM $vm -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            VMName       = $vm.Name
            BootOrder    = $bios.StartupOrder
            NumLockEnabled = $bios.NumLockEnabled
            Generation   = $vm.Generation
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
