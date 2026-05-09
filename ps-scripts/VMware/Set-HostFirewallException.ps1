#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Enables or disables host firewall exceptions
.DESCRIPTION
    Enables or disables a specific firewall exception on a host.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to modify the firewall exception
.PARAMETER ExceptionName
    Name of the firewall exception to modify
.PARAMETER Enabled
    If $true, the firewall exception is enabled
.EXAMPLE
    PS> ./Set-HostFirewallException.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -ExceptionName "sshServer" -Enabled $true
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
    [string]$ExceptionName,
    [bool]$Enabled
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $vmHost = Get-VMHost -Server $vmServer -Name $HostName -ErrorAction Stop
        $fireEx = Get-VMHostFirewallException -Server $vmServer -VMHost $vmHost -Name $ExceptionName -ErrorAction Stop
        $result = Set-VMHostFirewallException -Exception $fireEx -Enabled $Enabled -Confirm:$false -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
