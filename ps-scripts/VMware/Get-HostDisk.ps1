#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves information about the specified SCSI LUN disk
.DESCRIPTION
    Retrieves SCSI LUN disk information by host name or disk ID.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host to retrieve the hard disks attached to them; retrieves all if empty
.PARAMETER Id
    ID of the SCSI LUN disk to retrieve
.EXAMPLE
    PS> ./Get-HostDisk.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [string]$Id
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($HostName)) { $HostName = "*" }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ([System.String]::IsNullOrWhiteSpace($Id)) {
            $result = Get-VMHostDisk -Server $vmServer -VMHost $HostName -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-VMHostDisk -Server $vmServer -Id $Id -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
