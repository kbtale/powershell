#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets hub site properties
.DESCRIPTION
    Updates the hub site information such as name, logo, and description.
.PARAMETER Site
    URL of the hub site
.PARAMETER Title
    Display name of the hub
.PARAMETER Description
    Description of the hub site
.PARAMETER LogoUrl
    URL of a logo to use in the hub navigation
.PARAMETER RequiresJoinApproval
    Determines if joining the hub requires approval
.PARAMETER SiteDesignId
    Site design ID to associate with the hub
.EXAMPLE
    PS> ./Set-HubSite.ps1 -Site "https://contoso.sharepoint.com/sites/Hub" -Title "Corporate Hub"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [string]$Title,
    [string]$Description,
    [string]$LogoUrl,
    [bool]$RequiresJoinApproval,
    [string]$SiteDesignId
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Site }
        if (-not [System.String]::IsNullOrWhiteSpace($Title)) { $cmdArgs.Add('Title', $Title) }
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) { $cmdArgs.Add('Description', $Description) }
        if (-not [System.String]::IsNullOrWhiteSpace($LogoUrl)) { $cmdArgs.Add('LogoUrl', $LogoUrl) }
        if (-not [System.String]::IsNullOrWhiteSpace($SiteDesignId)) { $cmdArgs.Add('SiteDesignId', $SiteDesignId) }
        if ($PSBoundParameters.ContainsKey('RequiresJoinApproval')) { $cmdArgs.Add('RequiresJoinApproval', $RequiresJoinApproval) }
        Set-SPOHubSite @cmdArgs | Out-Null
        $result = Get-SPOHubSite -Identity $Site -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}