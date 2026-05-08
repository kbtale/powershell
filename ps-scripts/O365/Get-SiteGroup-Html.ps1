#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of site groups
.DESCRIPTION
    Generates an HTML report of groups for a site collection.
.PARAMETER Site
    URL of the site collection
.EXAMPLE
    PS> ./Get-SiteGroup-Html.ps1 -Site "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site }
        $result = Get-SPOSiteGroup @cmdArgs | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}