#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves available performance counters
.DESCRIPTION
    Retrieves performance counters by name from a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER CounterName
    Name of the counter to retrieve; retrieves all if empty
.PARAMETER Properties
    List of properties to expand; use * for all
.PARAMETER ExpandFields
    Expand the Fields property
.EXAMPLE
    PS> ./Get-Counters.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$CounterName = '*',
    [ValidateSet('*', 'Name', 'UId', 'Fields')]
    [string[]]$Properties = @('Name', 'UId', 'Fields'),
    [switch]$ExpandFields
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if (-not $ExpandFields) {
            $result = Get-EsxTop -Server $vmServer -Counter -CounterName $CounterName -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $result = Get-EsxTop -Server $vmServer -Counter -CounterName $CounterName -ErrorAction Stop | Select-Object -ExpandProperty Fields
        }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}