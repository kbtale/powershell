#Requires -Version 5.1
#Requires -Modules VMware.VimAutomation.Core
<#
.SYNOPSIS
    VMware: Retrieves diagnostic partitions on the specified hosts
.DESCRIPTION
    Retrieves a list of diagnostic partitions on the specified host.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER HostName
    Host for which to retrieve diagnostic partitions; retrieves all if empty
.PARAMETER All
    Retrieve all diagnostic partitions on the specified host
.EXAMPLE
    PS> ./Get-HostDiagnosticPartition.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -HostName "esxi01"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName,
    [switch]$All
)
Process {
    $vmServer = $null
    try {
        if ([System.String]::IsNullOrWhiteSpace($HostName)) { $HostName = "*" }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $result = Get-VMHostDiagnosticPartition -Server $vmServer -VMHost $HostName -All:$All -ErrorAction Stop | Select-Object *
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName 'Timestamp' -NotePropertyValue $timestamp -Force
            Write-Output $item
        }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
