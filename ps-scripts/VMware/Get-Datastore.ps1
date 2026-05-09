#Requires -Version 5.1

<#
.SYNOPSIS
    VMware: Retrieves datastores from vCenter
.DESCRIPTION
    Retrieves the datastores available on a vCenter Server system.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    Credentials for authenticating with the server
.PARAMETER Datastore
    Optional name of a specific datastore
.PARAMETER RefreshFirst
    Refresh storage system information before retrieval
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-Datastore.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Datastore,
    [switch]$RefreshFirst,
    [ValidateSet('*', 'Name', 'State', 'CapacityGB', 'FreeSpaceGB', 'Datacenter')]
    [string[]]$Properties = @('Name', 'State', 'CapacityGB', 'FreeSpaceGB', 'Datacenter')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ([System.String]::IsNullOrWhiteSpace($Datastore)) {
            $result = Get-Datastore -Server $vmServer -Refresh:$RefreshFirst -ErrorAction Stop | Select-Object $Properties
        }
        else { $result = Get-Datastore -Server $vmServer -Refresh:$RefreshFirst -Name $Datastore -ErrorAction Stop | Select-Object $Properties }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}
