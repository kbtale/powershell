#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes a virtual network adapter
.DESCRIPTION
    Removes a virtual network adapter from a VM.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER VMName
    Virtual machine from which to remove the network adapter
.PARAMETER AdapterName
    Name of the network adapter to remove; removes all if empty
.EXAMPLE
    PS> ./Remove-NetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -VMName "WebServer01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$AdapterName
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $vm = Get-VM -Server $vmServer -Name $VMName -ErrorAction Stop
        if ([System.String]::IsNullOrWhiteSpace($AdapterName)) { $adapter = Get-NetworkAdapter -Server $vmServer -VM $vm -ErrorAction Stop }
        else { $adapter = Get-NetworkAdapter -Server $vmServer -VM $vm -Name $AdapterName -ErrorAction Stop }
        if ($null -eq $adapter) { throw "No network adapter found" }
        $null = Remove-NetworkAdapter -NetworkAdapter $adapter -Confirm:$false -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Network adapter from VM $VMName successfully removed" }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}