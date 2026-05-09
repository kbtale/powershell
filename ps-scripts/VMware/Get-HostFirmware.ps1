#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves hosts firmware information
.DESCRIPTION
    Retrieves firmware information for a specified host, optionally backing up configuration.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host for which to retrieve firmware information
.PARAMETER BackupConfiguration
    Backup the host firmware configuration and download the bundle
.PARAMETER DestinationPath
    Destination path where to download the host configuration backup bundle
.EXAMPLE
    PS> ./Get-HostFirmware.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
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
    [switch]$BackupConfiguration,
    [string]$DestinationPath
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        if ($BackupConfiguration) {
            $result = Get-VMHostFirmware -Server $vmServer -VMHost $vmHost -BackupConfiguration -DestinationPath $DestinationPath -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-VMHostFirmware -Server $vmServer -VMHost $vmHost -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
