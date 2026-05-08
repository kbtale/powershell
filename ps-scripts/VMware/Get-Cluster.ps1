#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Retrieves clusters available on a vCenter Server system

    .DESCRIPTION
        Connects to a vCenter Server and retrieves clusters by ID, name, or virtual machine membership.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ClusterID
        ID of the cluster to retrieve

    .PARAMETER ClusterName
        Name of the cluster to retrieve; if empty, all clusters are retrieved

    .PARAMETER VM
        Name of a virtual machine to filter clusters that contain it

    .PARAMETER NoRecursion
        Disables recursive behavior of the command

    .PARAMETER Properties
        List of properties to expand; use * for all properties

    .EXAMPLE
        Get-Cluster -VIServer "vcenter.contoso.com" -VICredential $cred

    .EXAMPLE
        Get-Cluster -VIServer "vcenter.contoso.com" -VICredential $cred -ClusterName "ProdCluster"

    .CATEGORY VMware
#>

[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$ClusterID,
    [Parameter(Mandatory = $true, ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byVM")]
    [ValidateSet('*', 'Name', 'Id', 'HATotalSlots', 'HAUsedSlots', 'HAEnabled', 'HASlotMemoryGB', 'HASlotNumVCpus')]
    [string[]]$Properties = @('Name', 'Id', 'HATotalSlots', 'HAUsedSlots', 'HAEnabled', 'HASlotMemoryGB', 'HASlotNumVCpus')
)

Process {
    $vmServer = $null
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $result = Get-Cluster -Server $vmServer -Id $ClusterID -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
        }
        elseif ($PSCmdlet.ParameterSetName -eq "byVM") {
            $result = Get-Cluster -Server $vmServer -VM $VM -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
        }
        else {
            if ([System.String]::IsNullOrWhiteSpace($ClusterName)) {
                $result = Get-Cluster -Server $vmServer -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
            }
            else {
                $result = Get-Cluster -Server $vmServer -Name $ClusterName -NoRecursion:$NoRecursion -ErrorAction Stop | Select-Object $Properties
            }
        }

        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch {
        throw
    }
    finally {
        if ($null -ne $vmServer) {
            Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
}
