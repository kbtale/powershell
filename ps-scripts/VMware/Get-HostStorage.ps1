#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the host storages on a vCenter Server system
.DESCRIPTION
    Retrieves host storage information, optionally with refresh and rescan options.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to retrieve storage information
.PARAMETER Id
    ID of the host storage to retrieve
.PARAMETER Refresh
    Refresh the storage system information before retrieving
.PARAMETER RescanAllHba
    Rescan all host bus adapters for new storage devices
.PARAMETER RescanVmfs
    Re-scan for new virtual machine file systems
.EXAMPLE
    PS> ./Get-HostStorage.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [string]$Id,
    [switch]$Refresh,
    [switch]$RescanAllHba,
    [switch]$RescanVmfs
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ([System.String]::IsNullOrWhiteSpace($Id)) {
            $result = Get-VmHostStorage -Server $vmServer -VMHost $HostName -Refresh:$Refresh -RescanAllHba:$RescanAllHba -RescanVmfs:$RescanVmfs -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-VmHostStorage -Server $vmServer -ID $Id -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
