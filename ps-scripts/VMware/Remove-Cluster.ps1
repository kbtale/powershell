#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Removes the specified cluster

    .DESCRIPTION
        Connects to a vCenter Server and removes a cluster by ID or name.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ClusterID
        ID of the cluster to remove

    .PARAMETER ClusterName
        Name of the cluster to remove

    .EXAMPLE
        Remove-Cluster -VIServer "vcenter.contoso.com" -VICredential $cred -ClusterName "OldCluster"

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
    [string]$ClusterName
)

Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

        if ($PSCmdlet.ParameterSetName -eq "byID") {
            $cluster = Get-Cluster -Server $vmServer -Id $ClusterID -ErrorAction Stop
        }
        else {
            $cluster = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop
        }
        $clusterName = $cluster.Name
        $null = Remove-Cluster -Cluster $cluster -Server $vmServer -Confirm:$false -ErrorAction Stop

        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Cluster $clusterName successfully removed"
        }
        Write-Output $output
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
