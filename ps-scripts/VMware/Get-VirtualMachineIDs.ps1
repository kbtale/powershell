#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves the IDs of the virtual machines on a vCenter Server system
.DESCRIPTION

.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.EXAMPLE
    PS> ./Get-VirtualMachineIDs.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = Get-VM -Server $vmServer -ErrorAction Stop | Sort-Object Name
        foreach ($item in $result) {
            [PSCustomObject]@{
                Timestamp    = $timestamp
                Value        = $item.Id
                DisplayValue = "$($item.Name) - $($item.PowerState)"
            }
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}