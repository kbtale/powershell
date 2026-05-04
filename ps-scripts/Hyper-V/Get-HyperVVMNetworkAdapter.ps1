#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine network adapters

.DESCRIPTION
    Retrieves detailed configuration for all network adapters attached to a Microsoft Hyper-V virtual machine, including MAC addresses, IP addresses, and switch connectivity.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.EXAMPLE
    PS> ./Get-HyperVVMNetworkAdapter.ps1 -Name "Linux-Web"

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

        $adapters = Get-VMNetworkAdapter -VM $vm | ForEach-Object {
            $vlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $_
            [PSCustomObject]@{
                VMName            = $vm.Name
                AdapterName       = $_.Name
                MacAddress        = $_.MacAddress
                Connected         = $_.Connected
                SwitchName        = $_.SwitchName
                IPAddresses       = $_.IPAddresses
                VlanEnabled       = $vlan.Access
                VlanId            = $vlan.VlanId
                Status            = $_.Status
                StatusDescription = $_.StatusDescription
            }
        }

        Write-Output $adapters
    }
    catch {
        throw
    }
}
