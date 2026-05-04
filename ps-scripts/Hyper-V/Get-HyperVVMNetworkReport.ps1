#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Generates a comprehensive virtual network report

.DESCRIPTION
    Retrieves a consolidated report of all virtual network adapters (VM and Management OS) on a Microsoft Hyper-V host, including switch connectivity, MAC addresses, and VLAN details.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER IncludeVlan
    Optional. If set, includes detailed VLAN configuration for each adapter.

.PARAMETER IncludeManagementOS
    Optional. If set, includes network adapters from the Management OS.

.EXAMPLE
    PS> ./Get-HyperVVMNetworkReport.ps1 -IncludeVlan -IncludeManagementOS

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [switch]$IncludeVlan,

    [switch]$IncludeManagementOS
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }

        $adapters = New-Object System.Collections.Generic.List[PSObject]

        # Get VM adapters
        $vmAdapters = Get-VMNetworkAdapter @params -All
        foreach ($ada in $vmAdapters) {
            $record = [PSCustomObject]@{
                Owner       = $ada.VMName
                AdapterName = $ada.Name
                SwitchName  = $ada.SwitchName
                MacAddress  = $ada.MacAddress
                Status      = $ada.Status
                Type        = "VirtualMachine"
            }
            if ($IncludeVlan) {
                $vlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $ada
                $record | Add-Member -MemberType NoteProperty -Name "VlanMode" -Value $vlan.OperationMode
                $record | Add-Member -MemberType NoteProperty -Name "VlanId" -Value $vlan.AccessVlanId
            }
            $adapters.Add($record)
        }

        # Get Management OS adapters
        if ($IncludeManagementOS) {
            $mgmtAdapters = Get-VMNetworkAdapter @params -ManagementOS
            foreach ($ada in $mgmtAdapters) {
                $record = [PSCustomObject]@{
                    Owner       = "ManagementOS"
                    AdapterName = $ada.Name
                    SwitchName  = $ada.SwitchName
                    MacAddress  = $ada.MacAddress
                    Status      = $ada.Status
                    Type        = "Host"
                }
                if ($IncludeVlan) {
                    $vlan = Get-VMNetworkAdapterVlan -VMNetworkAdapter $ada
                    $record | Add-Member -MemberType NoteProperty -Name "VlanMode" -Value $vlan.OperationMode
                    $record | Add-Member -MemberType NoteProperty -Name "VlanId" -Value $vlan.AccessVlanId
                }
                $adapters.Add($record)
            }
        }

        Write-Output ($adapters | Sort-Object Owner, AdapterName)
    }
    catch {
        throw
    }
}
