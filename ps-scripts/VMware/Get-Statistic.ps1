#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves statistical information from a vCenter Server system
.DESCRIPTION
    Retrieves common CPU, disk, memory, and network statistics from a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Common
    Collects common CPU, disk, memory, and network statistics
.PARAMETER CPU
    Collects common CPU statistics
.PARAMETER Memory
    Collects common memory statistics
.PARAMETER Disk
    Collects common disk statistics
.PARAMETER Network
    Collects common network statistics
.PARAMETER MaxResult
    Maximum number of results to retrieve (1-100)
.EXAMPLE
    PS> ./Get-Statistic.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Common -MaxResult 50
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [switch]$Common,
    [switch]$CPU,
    [switch]$Memory,
    [switch]$Disk,
    [switch]$Network,
    [ValidateRange(1, 100)]
    [int]$MaxResult = 20
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = Get-Stat -Server $vmServer -Common:$Common -Memory:$Memory -Cpu:$CPU -Disk:$Disk -Network:$Network -ErrorAction Stop | Select-Object -First $MaxResult
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}