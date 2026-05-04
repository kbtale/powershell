#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Configures firmware settings for Gen 2 virtual machines

.DESCRIPTION
    Updates firmware configuration for Microsoft Hyper-V Generation 2 virtual machines, including secure boot, boot order, and network boot protocols.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER SecureBoot
    Optional. Specifies whether Secure Boot is enabled ($true) or disabled ($false).

.PARAMETER BootOrder
    Optional. Specifies the boot order of device types (File, DVDDrive, HardDiskDrive, NetworkAdapter).

.PARAMETER PreferredNetworkBootProtocol
    Optional. Specifies the preferred network boot protocol (IPv4 or IPv6).

.EXAMPLE
    PS> ./Set-HyperVVMFirmware.ps1 -Name "WinSrv-2022" -SecureBoot $true -BootOrder HardDiskDrive, NetworkAdapter

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [bool]$SecureBoot,

    [ValidateSet('File', 'DVDDrive', 'HardDiskDrive', 'NetworkAdapter')]
    [string[]]$BootOrder,

    [ValidateSet('IPv4', 'IPv6')]
    [string]$PreferredNetworkBootProtocol
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
            throw "Virtual machine '$Name' is Generation $($vm.Generation). Firmware settings only apply to Generation 2. Use Set-HyperVVMBIOS for Generation 1."
        }

        $firmwareParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        
        if ($PSBoundParameters.ContainsKey('SecureBoot')) {
            $firmwareParams.Add('EnableSecureBoot', ([string]$SecureBoot))
        }

        if ($BootOrder) {
            $devices = @()
            $allDevices = Get-VMFirmware -VM $vm | Select-Object -ExpandProperty BootOrder
            foreach ($type in $BootOrder) {
                $found = $allDevices | Where-Object { $_.DeviceType -eq $type }
                if ($found) { $devices += $found }
            }
            if ($devices) { $firmwareParams.Add('BootOrder', $devices) }
        }

        if ($PreferredNetworkBootProtocol) {
            $firmwareParams.Add('PreferredNetworkBootProtocol', $PreferredNetworkBootProtocol)
        }

        if ($firmwareParams.Count -gt 2) {
            Set-VMFirmware @firmwareParams
        }

        $updatedFirmware = Get-VMFirmware -VM $vm
        
        $result = [PSCustomObject]@{
            VMName                       = $vm.Name
            Generation                   = $vm.Generation
            SecureBoot                   = $updatedFirmware.SecureBoot
            BootOrder                    = $updatedFirmware.BootOrder.DeviceType
            PreferredNetworkBootProtocol = $updatedFirmware.PreferredNetworkBootProtocol
            Action                       = "FirmwareConfigUpdated"
            Status                       = "Success"
            Timestamp                    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
