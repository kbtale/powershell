#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves time zones available on a specified host
.DESCRIPTION
    Retrieves available time zones from hosts on a vCenter Server.
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER TimezoneName
    Name of the time zone to retrieve; retrieves all if empty
.EXAMPLE
    PS> ./Get-AvailableTimezones.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$TimezoneName = '*'
)
Process {
    try {
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        $result = Get-VMHostAvailableTimeZone -Server $vmServer -Name $TimezoneName -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}