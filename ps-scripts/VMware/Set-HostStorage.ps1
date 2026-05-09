#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Configures host storage settings
.DESCRIPTION
    Enables or disables software iSCSI on a specified host storage.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to configure host storage
.PARAMETER Id
    ID of the host storage to configure
.PARAMETER SoftwareIScsiEnabled
    Enable software iSCSI on this storage
.EXAMPLE
    PS> ./Set-HostStorage.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -Id "storage1" -SoftwareIScsiEnabled $true
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [bool]$SoftwareIScsiEnabled
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = Get-VmHostStorage -Server $vmServer -ID $Id -VMHost $HostName -ErrorAction Stop | Set-VMHostStorage -SoftwareIScsiEnabled $SoftwareIScsiEnabled -Confirm:$false -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
