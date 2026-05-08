#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a group from a site collection
.DESCRIPTION
    Deletes a SharePoint Online group from a specific site collection.
.PARAMETER Site
    URL of the site collection the group belongs to
.PARAMETER Group
    Name of the group to remove
.EXAMPLE
    PS> ./Remove-SiteGroup.ps1 -Site "https://contoso.sharepoint.com/sites/MySite" -Group "Team Members"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [string]$Group
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site; Identity = $Group }
        Remove-SPOSiteGroup @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site group '$Group' removed from '$Site'" }
    }
    catch { throw }
}