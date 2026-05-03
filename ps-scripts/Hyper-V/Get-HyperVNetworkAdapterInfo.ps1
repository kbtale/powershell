#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Retrieves properties of a specific Hyper-V network adapter

.DESCRIPTION
    Gets detailed properties for a specified Microsoft Hyper-V virtual network adapter, including status, MAC addresses, and optional VLAN configuration.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER Name
    Specifies the name of the network adapter to retrieve.

.PARAMETER ManagementOS
    If set, retrieves adapters from the management OS instead of virtual machines.

.PARAMETER IncludeVlan
    If set, includes VLAN configuration properties in the output.

.EXAMPLE
    PS> ./Get-HyperVNetworkAdapterInfo.ps1 -Name "External" -ManagementOS

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [switch]$ManagementOS,

    [switch]$IncludeVlan
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'Name'         = $Name
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        if ($ManagementOS) { $params.Add('ManagementOS', $true) }

        $adapter = Get-VMNetworkAdapter @params
        
        $results = foreach ($a in $adapter) {
            $obj = [PSCustomObject]@{
                Name           = $a.Name
                SwitchName     = $a.SwitchName
                MacAddress     = $a.MacAddress
                Status         = $a.Status
                IsManagementOs = $a.IsManagementOs
                IsExternal     = $a.IsExternalAdapter
                ComputerName   = $a.ComputerName
            }

            if ($IncludeVlan) {
                $vlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $a -ErrorAction SilentlyContinue
                if ($vlan) {
                    $obj | Add-Member -MemberType NoteProperty -Name "VlanMode" -Value $vlan.OperationMode
                    $obj | Add-Member -MemberType NoteProperty -Name "VlanId" -Value $vlan.AccessVlanId
                }
            }
            $obj
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
