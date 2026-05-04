#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits virtual machine VLAN settings

.DESCRIPTION
    Retrieves the virtual LAN (VLAN) configuration for a specifies virtual network adapter on a Microsoft Hyper-V virtual machine.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name or ID of the virtual machine.

.PARAMETER AdapterName
    Optional. Specifies the name of the network adapter. If not provided, all adapters are audited.

.EXAMPLE
    PS> ./Get-HyperVVMVLAN.ps1 -Name "AppSrv" -AdapterName "Network Adapter"

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$AdapterName
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

        $vlanParams = @{ 'VM' = $vm; 'ErrorAction' = 'Stop' }
        if ($AdapterName) {
            $vlanParams.Add('VMNetworkAdapterName', $AdapterName)
        }

        $results = Get-VMNetworkAdapterVlan @vlanParams | Select-Object @{N='VMName';E={$vm.Name}}, VMNetworkAdapterName, OperationMode, AccessVlanId, CommunityVlanId, IsolatedVlanId, PrimaryVlanId

        Write-Output $results
    }
    catch {
        throw
    }
}
