#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the exceptions from the firewall policy on the specified host
.DESCRIPTION
    Retrieves firewall exceptions for a specified host, optionally filtered by port and enabled state.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to retrieve firewall exceptions
.PARAMETER PortNumber
    Filter by port number
.PARAMETER Enabled
    Filter to only retrieve enabled exceptions
.EXAMPLE
    PS> ./Get-HostFirewallException.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
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
    [int32]$PortNumber,
    [bool]$Enabled
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        if ($PortNumber -gt 0) {
            $result = Get-VMHostFirewallException -Server $vmServer -VMHost $vmHost -Enabled $Enabled -Port $PortNumber -ErrorAction Stop | Select-Object *
        }
        else {
            $result = Get-VMHostFirewallException -Server $vmServer -VMHost $vmHost -Enabled $Enabled -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
