#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of users
.DESCRIPTION
    Generates an HTML report of SharePoint Online users in a site collection.
.PARAMETER Site
    URL of the site collection
.PARAMETER Limit
    Maximum number of users to return
.EXAMPLE
    PS> ./Get-User-Html.ps1 -Site "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [int]$Limit = 500
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site; Limit = $Limit }
        $result = Get-SPOUser @cmdArgs | Select-Object DisplayName, LoginName, IsSiteAdmin, IsGroup, Groups, UserType | Sort-Object DisplayName
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}