#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets org news site
.DESCRIPTION
    Designates an organization news site.
.PARAMETER SiteUrl
    URL of the site to set as org news site
.EXAMPLE
    PS> ./Set-OrgNewsSite.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/news"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl
)

Process {
    try {
        Set-SPOOrgNewsSite -OrgNewsSiteUrl $SiteUrl -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Org news site set to '$SiteUrl'" }
    }
    catch { throw }
}
