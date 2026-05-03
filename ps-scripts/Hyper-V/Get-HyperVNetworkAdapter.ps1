#Requires -Version 5.1
#Requires -Modules Hyper-V

<#
.SYNOPSIS
    Hyper-V: Lists all network adapters on a Hyper-V host

.DESCRIPTION
    Retrieves an inventory of all virtual network adapters on a specified Hyper-V host. Supports listing adapters from the management OS and all virtual machines.

.PARAMETER ComputerName
    Specifies the name of the Hyper-V host. Defaults to the local machine.

.PARAMETER Credential
    Specifies the credentials to use for the remote connection.

.PARAMETER All
    If set, retrieves adapters from both the management OS and all virtual machines. Defaults to ManagementOS only.

.PARAMETER IncludeVlan
    If set, includes VLAN configuration properties in the output.

.EXAMPLE
    PS> ./Get-HyperVNetworkAdapter.ps1 -All -IncludeVlan

.CATEGORY Hyper-V
#>

[CmdletBinding()]
Param (
    [string]$ComputerName = "localhost",

    [PSCredential]$Credential,

    [switch]$All,

    [switch]$IncludeVlan
)

Process {
    try {
        $params = @{
            'ComputerName' = $ComputerName
            'ErrorAction'  = 'Stop'
        }
        if ($Credential) { $params.Add('Credential', $Credential) }
        
        if ($All) {
            $params.Add('All', $true)
        }
        else {
            $params.Add('ManagementOS', $true)
        }

        $adapters = Get-VMNetworkAdapter @params
        
        $results = foreach ($a in $adapters) {
            $obj = [PSCustomObject]@{
                Name           = $a.Name
                VMName         = if ($a.VMName) { $a.VMName } else { "ManagementOS" }
                SwitchName     = $a.SwitchName
                MacAddress     = $a.MacAddress
                Status         = $a.Status
                IsManagementOs = $a.IsManagementOs
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

        Write-Output ($results | Sort-Object VMName, Name)
    }
    catch {
        throw
    }
}
