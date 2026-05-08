#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Connects a site collection to an Office 365 Group
.DESCRIPTION
    Connects a top-level SharePoint Online site collection to a new Office 365 Group.
.PARAMETER Site
    The site collection to connect to an Office 365 Group
.PARAMETER Alias
    Email alias for the new Office 365 Group
.PARAMETER DisplayName
    Name of the new Office 365 Group
.PARAMETER Classification
    Classification value for the group
.PARAMETER Description
    Description of the group
.PARAMETER IsPublic
    Determines the group privacy setting (public if specified)
.PARAMETER KeepOldHomepage
    Keep the existing modern page as homepage
.EXAMPLE
    PS> ./Set-SiteOffice365Group.ps1 -Site "https://contoso.sharepoint.com/sites/MySite" -DisplayName "My Group" -Alias "mygroup"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [string]$Alias,
    [string]$Classification,
    [string]$Description,
    [switch]$IsPublic,
    [switch]$KeepOldHomepage
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site; DisplayName = $DisplayName; Alias = $Alias; IsPublic = $IsPublic; KeepOldHomepage = $KeepOldHomepage }
        if ($PSBoundParameters.ContainsKey('Classification')) { $cmdArgs.Add('Classification', $Classification) }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        $result = Set-SPOSiteOffice365Group @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}