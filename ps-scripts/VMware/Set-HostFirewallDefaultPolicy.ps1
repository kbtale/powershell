#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Sets the default policy for the specified host firewall
.DESCRIPTION
    Configures allow incoming and outgoing connections for the host firewall.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host whose firewall default policy to modify
.PARAMETER AllowOutgoing
    If $true, all outgoing connections are allowed
.PARAMETER AllowIncoming
    If $true, all incoming connections are allowed
.EXAMPLE
    PS> ./Set-HostFirewallDefaultPolicy.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -AllowIncoming $true
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
    [bool]$AllowOutgoing = $true,
    [bool]$AllowIncoming = $true
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $defPolicy = Get-VMHostFirewallDefaultPolicy -Server $vmServer -VMHost $vmHost -ErrorAction Stop
        $output = $defPolicy | Select-Object *
        if ($PSBoundParameters.ContainsKey('AllowIncoming')) {
            $output = Set-VMHostFirewallDefaultPolicy -Policy $defPolicy -AllowIncoming $AllowIncoming -Confirm:$false -ErrorAction Stop | Select-Object *
        }
        if ($PSBoundParameters.ContainsKey('AllowOutgoing')) {
            $output = Set-VMHostFirewallDefaultPolicy -Policy $defPolicy -AllowOutgoing $AllowOutgoing -Confirm:$false -ErrorAction Stop | Select-Object *
        }
        foreach ($item in $output) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
