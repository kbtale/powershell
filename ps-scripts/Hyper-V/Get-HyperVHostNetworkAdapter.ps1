#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Audits host management network adapters

.DESCRIPTION
    Retrieves detailed configuration for network adapters associated with the Management OS on a Microsoft Hyper-V host, including switch connectivity, MAC addresses, and VLAN details.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Optional. Specifies the name of a specific management network adapter.

.PARAMETER IncludeVlan
    Optional. If set, includes detailed VLAN configuration for the adapters.

.EXAMPLE
    PS> ./Get-HyperVHostNetworkAdapter.ps1 -IncludeVlan

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [string]$Name = "*",

    [switch]$IncludeVlan
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ManagementOS' = $true
            'Name'         = $Name
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $adapters = Get-VMNetworkAdapter @params
        
        $results = foreach ($ada in $adapters) {
            $record = [PSCustomObject]@{
                ComputerName = $ada.ComputerName
                AdapterName  = $ada.Name
                SwitchName   = $ada.SwitchName
                MacAddress   = $ada.MacAddress
                Status       = $ada.Status
                IsManagement = $ada.IsManagementOs
            }
            if ($IncludeVlan) {
                $vlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $ada
                $record | Add-Member -MemberType NoteProperty -Name "VlanMode" -Value $vlan.OperationMode
                $record | Add-Member -MemberType NoteProperty -Name "VlanId" -Value $vlan.AccessVlanId
            }
            $record
        }

        Write-Output ($results | Sort-Object AdapterName)
    }
    catch {
        throw
    }
}
