#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the host network adapters on a vCenter Server system
.DESCRIPTION
    Retrieves host network adapters, optionally filtered by type, name, or port group.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host whose network adapters to retrieve; retrieves all if empty
.PARAMETER Console
    Retrieve only service console virtual network adapters
.PARAMETER Physical
    Retrieve only physical network adapters
.PARAMETER VMKernel
    Retrieve only VMKernel virtual network adapters
.PARAMETER AdapterName
    Name of the host network adapter to retrieve
.PARAMETER PortGroupName
    Name of the port group to filter by
.EXAMPLE
    PS> ./Get-HostNetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [switch]$Console,
    [switch]$Physical,
    [switch]$VMKernel,
    [string]$AdapterName,
    [string]$PortGroupName
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($HostName)) { $HostName = "*" }
        if ([System.String]::IsNullOrWhiteSpace($AdapterName)) { $AdapterName = "*" }
        if ([System.String]::IsNullOrWhiteSpace($PortGroupName)) { $PortGroupName = "*" }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = Get-VMHostNetworkAdapter -Server $vmServer -Console:$Console -Physical:$Physical -VMKernel:$VMKernel -Name $AdapterName -PortGroup $PortGroupName -VMHost $HostName -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
