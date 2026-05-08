#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Grants site design rights
.DESCRIPTION
    Assigns rights to a site design to principals.
.PARAMETER Identity
    Site design ID
.PARAMETER Principal
    Principals to grant rights to
.PARAMETER Rights
    Rights to grant
.EXAMPLE
    PS> ./Grant-SiteDesignRights.ps1 -Identity "guid" -Principal @("user@contoso.com") -Rights View
.CATEGORY O365
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][guid]$Identity,
    [Parameter(Mandatory = $true)][string[]]$Principal,
    [Parameter(Mandatory = $true)][ValidateSet('None', 'View')][string]$Rights
)
Process {
    try {
        Grant-SPOSiteDesignRights -Identity $Identity -Principals $Principal -Rights $Rights -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site design rights granted" }
    }
    catch { throw }
}
