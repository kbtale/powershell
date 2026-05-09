#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Formats a new VMFS on each of the specified host disk partition
.DESCRIPTION
    Formats a new Virtual Machine File System on a specified host disk partition.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Id
    Disk partition on which to format a new VMFS
.PARAMETER VolumeName
    Name for the new VMFS volume
.EXAMPLE
    PS> ./Format-HostDiskPartition.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Id "partition1" -VolumeName "MyVolume"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [string]$VolumeName
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ([System.String]::IsNullOrWhiteSpace($VolumeName)) {
            $result = Get-VMHostDiskPartition -Server $vmServer -Id $Id | Format-VMHostDiskPartition -Confirm:$false -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-VMHostDiskPartition -Server $vmServer -Id $Id | Format-VMHostDiskPartition -Confirm:$false -VolumeName $VolumeName -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
