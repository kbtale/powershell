#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a site from its associated hub site
.DESCRIPTION
    Disassociates a site from the hub site it is connected to.
.PARAMETER Site
    URL of the site to remove from the hub site
.EXAMPLE
    PS> ./Remove-HubSiteAssociation.ps1 -Site "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site
)

Process {
    try {
        Remove-SPOHubSiteAssociation -Site $Site -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site '$Site' removed from hub association" }
    }
    catch { throw }
}