#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Modifies the configuration of a cluster

    .DESCRIPTION
        Connects to a vCenter Server and modifies HA, DRS, and name settings of a specified cluster.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ClusterID
        ID of the cluster to modify

    .PARAMETER ClusterName
        Name of the cluster to modify

    .PARAMETER DrsAutomationLevel
        DRS (Distributed Resource Scheduler) automation level

    .PARAMETER DrsEnabled
        Enables VMware DRS

    .PARAMETER HAAdmissionControlEnabled
        Prevents VMs from starting if they violate availability constraints

    .PARAMETER HAEnabled
        Enables VMware High Availability

    .PARAMETER HAFailoverLevel
        Failover level (1-4)

    .PARAMETER HAIsolationResponse
        Response when a host becomes isolated

    .PARAMETER HARestartPriority
        Cluster HA restart priority

    .PARAMETER NewName
        New name for the cluster

    .EXAMPLE
        Set-Cluster -VIServer "vcenter.contoso.com" -VICredential $cred -ClusterName "ProdCluster" -HAEnabled $true

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
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated")]
    [string]$DrsAutomationLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$DrsEnabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$HAAdmissionControlEnabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [bool]$HAEnabled,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateRange(1, 4)]
    [int32]$HAFailoverLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("PowerOff ", "DoNothing")]
    [string]$HAIsolationResponse,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Disabled ", "Low", "Medium", "High")]
    [string]$HARestartPriority,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$NewName
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
        if ($PSBoundParameters.ContainsKey('DrsEnabled')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -DrsEnabled $DrsEnabled -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('HAAdmissionControlEnabled')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -HAAdmissionControlEnabled $HAAdmissionControlEnabled -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('HAEnabled')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -HAEnabled $HAEnabled -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('HARestartPriority')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -HARestartPriority $HARestartPriority -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('HAIsolationResponse')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -HAIsolationResponse $HAIsolationResponse -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('HAFailoverLevel')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -HAFailoverLevel $HAFailoverLevel -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('DrsAutomationLevel')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -DrsAutomationLevel $DrsAutomationLevel -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('NewName')) {
            Set-Cluster -Cluster $cluster -Server $vmServer -Name $NewName -ErrorAction Stop
        }

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
