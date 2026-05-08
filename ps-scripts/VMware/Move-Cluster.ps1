#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Moves a vCenter Server cluster from one location to another

    .DESCRIPTION
        Connects to a vCenter Server and moves a specified cluster to a destination folder.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ClusterID
        ID of the cluster to move

    .PARAMETER ClusterName
        Name of the cluster to move

    .PARAMETER DestinationName
        Name of the destination folder

    .EXAMPLE
        Move-Cluster -VIServer "vcenter.contoso.com" -VICredential $cred -ClusterName "TestCluster" -DestinationName "ProdFolder"

    .CATEGORY VMware
#>

[CmdletBinding(DefaultParameterSetName = "byName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [string]$ClusterID,
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$ClusterName,
    [Parameter(Mandatory = $true, ParameterSetName = "byID")]
    [Parameter(Mandatory = $true, ParameterSetName = "byName")]
    [string]$DestinationName
)

Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'HATotalSlots', 'HAUsedSlots', 'HAEnabled', 'HASlotMemoryGB', 'HASlotNumVCpus')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $cluster = Get-Cluster -Server $vmServer -Id $ClusterID -ErrorAction Stop
        }
        else {
            $cluster = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop
        }
        $destination = Get-Folder -Server $vmServer -Name $DestinationName -ErrorAction Stop
        if ($null -eq $destination) {
            throw "Destination $DestinationName not found"
        }
        $null = Move-Cluster -Cluster $cluster -Destination $destination -Server $vmServer -Confirm:$false -ErrorAction Stop
        $result = Get-Cluster -Server $vmServer -Name $cluster.Name -ErrorAction Stop | Select-Object $Properties
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

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
