#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Grants hub site rights
.DESCRIPTION
    Assigns hub site join rights to principals.
.PARAMETER HubSiteId
    Hub site ID
.PARAMETER Principal
    Principal to grant rights to
.PARAMETER Rights
    Rights to grant
.EXAMPLE
    PS> ./Grant-HubSiteRights.ps1 -HubSiteId "guid" -Principal "user@contoso.com" -Rights Join
.CATEGORY O365
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][guid]$HubSiteId,
    [Parameter(Mandatory = $true)][string[]]$Principal,
    [Parameter(Mandatory = $true)][ValidateSet('None', 'Join')][string]$Rights
)
Process {
    try {
        Grant-SPOHubSiteRights -Identity $HubSiteId -Principals $Principal -Rights $Rights -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Hub site rights granted" }
    }
    catch { throw }
}
