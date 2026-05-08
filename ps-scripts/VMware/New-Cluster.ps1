#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        VMware: Creates a new cluster

    .DESCRIPTION
        Connects to a vCenter Server and creates a new cluster with specified HA and DRS settings.

    .PARAMETER VIServer
        IP address or DNS name of the vSphere server

    .PARAMETER VICredential
        PSCredential object for authenticating with the server

    .PARAMETER ClusterName
        Name for the new cluster

    .PARAMETER LocationName
        Datacenter name or folder name where the cluster will be placed

    .PARAMETER DrsAutomationLevel
        DRS (Distributed Resource Scheduler) automation level

    .PARAMETER DrsEnabled
        Enables VMware DRS (Distributed Resource Scheduler)

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

    .EXAMPLE
        New-Cluster -VIServer "vcenter.contoso.com" -VICredential $cred -ClusterName "NewCluster" -LocationName "Datacenter01"

    .CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$ClusterName,
    [Parameter(Mandatory = $true)]
    [string]$LocationName,
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated")]
    [string]$DrsAutomationLevel,
    [switch]$DrsEnabled,
    [switch]$HAAdmissionControlEnabled,
    [switch]$HAEnabled,
    [ValidateRange(1, 4)]
    [int32]$HAFailoverLevel,
    [ValidateSet("PowerOff ", "DoNothing")]
    [string]$HAIsolationResponse,
    [ValidateSet("Disabled ", "Low", "Medium", "High")]
    [string]$HARestartPriority
)

Process {
    $vmServer = $null
    try {
        [string[]]$Properties = @('Name', 'Id', 'HATotalSlots', 'HAUsedSlots', 'HAEnabled', 'HASlotMemoryGB', 'HASlotNumVCpus')
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

        $location = Get-Folder -Server $vmServer -Name $LocationName -ErrorAction Stop
        if ($null -eq $location) {
            throw "Location $LocationName not found"
        }
        $null = New-Cluster -Name $ClusterName -Location $location -Server $vmServer -HAAdmissionControlEnabled:$HAAdmissionControlEnabled -HAEnabled:$HAEnabled -DrsEnabled:$DrsEnabled -ErrorAction Stop
        $cluster = Get-Cluster -Server $vmServer -Name $ClusterName -ErrorAction Stop

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
