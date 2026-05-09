#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Removes the specified host network adapter
.DESCRIPTION
    Removes a host network adapter by name from the vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Name of the host whose network adapter to remove
.PARAMETER AdapterName
    Name of the host network adapter to remove
.EXAMPLE
    PS> ./Remove-HostNetworkAdapter.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -AdapterName "vmk1"
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
    [string]$AdapterName
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $vAdapter = Get-VMHostNetworkAdapter -Server $vmServer -Name $AdapterName -VMHost $HostName -ErrorAction Stop
        $null = Remove-VMHostNetworkAdapter -Nic $vAdapter -Confirm:$false -ErrorAction Stop
        $output = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status    = "Success"
            Message   = "Adapter $AdapterName successfully removed"
        }
        Write-Output $output
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
