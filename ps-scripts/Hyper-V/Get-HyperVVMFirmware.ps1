#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits Generation 2 virtual machine firmware configuration

.DESCRIPTION
    Retrieves the UEFI firmware configuration for a specifies Microsoft Hyper-V Generation 2 virtual machine, including boot order and Secure Boot status.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMFirmware.ps1 -Name "ModernSrv-01"

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

        if ($vm.Generation -ne 2) {
            throw "Firmware (UEFI) configuration is only supported on Generation 2 virtual machines. VM '$Name' is Generation $($vm.Generation)."
        }

        $fw = Get-VMFirmware -VM $vm -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            VMName            = $vm.Name
            SecureBoot        = $fw.SecureBoot
            BootOrder         = $fw.BootOrder | ForEach-Object { "$($_.FirmwareAddress) ($($_.Description))" }
            PreferredBootOrder = $fw.BootOrder | Select-Object -ExpandProperty Description
            Generation        = $vm.Generation
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
