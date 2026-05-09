#Requires -Version 5.1
<#
.SYNOPSIS
    VMware: Retrieves information about current or recent tasks
.DESCRIPTION
    Retrieves tasks filtered by status (Error, Queued, Running, Success).
.PARAMETER VIServer
    IP address or DNS name of the vSphere server
.PARAMETER VICredential
    PSCredential object for authenticating with the server
.PARAMETER Status
    Status filter: Error, Queued, Running, Success
.PARAMETER Properties
    List of properties to expand; use * for all
.EXAMPLE
    PS> ./Get-Task.ps1 -VIServer "vcenter.contoso.com" -VICredential $cred -Status "Running"
.CATEGORY VMware
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [ValidateSet("Error", "Queued", "Running", "Success")]
    [string]$Status,
    [ValidateSet('*', 'Description', 'State', 'IsCancelable', 'StartTime', 'FinishTime', 'PercentComplete', 'Name')]
    [string[]]$Properties = @('Description', 'State', 'IsCancelable', 'StartTime', 'FinishTime', 'PercentComplete', 'Name')
)
Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
        if ([System.String]::IsNullOrWhiteSpace($Status)) { $result = Get-Task -Server $vmServer -ErrorAction Stop | Select-Object $Properties }
        else { $result = Get-Task -Server $vmServer -Status $Status -ErrorAction Stop | Select-Object $Properties }
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { if ($null -ne $vmServer) { Disconnect-VIServer -Server $vmServer -Force -Confirm:$false -ErrorAction SilentlyContinue } }
}