#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Activates or deactivates the diagnostic partitions of host
.DESCRIPTION
    Sets the active state of diagnostic partitions on a specified host.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to modify diagnostic partitions
.PARAMETER Active
    If $true, activates the partition; if $false, deactivates it
.EXAMPLE
    PS> ./Set-HostDiagnosticPartition.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01" -Active $true
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
    [bool]$Active
)
Process {
    $vmServer = $null
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = Get-VMHostDiagnosticPartition -Server $vmServer -VMHost $HostName -ErrorAction Stop | Set-VMHostDiagnosticPartition -Active $Active -Confirm:$false -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
