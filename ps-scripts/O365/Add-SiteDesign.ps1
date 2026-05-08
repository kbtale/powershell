#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Adds a site design
.DESCRIPTION
    Creates a new site design that can be applied to sites.
.PARAMETER Title
    Display name of the site design
.PARAMETER WebTemplate
    SharePoint web template
.PARAMETER SiteScripts
    Site script IDs to associate
.PARAMETER Description
    Optional description
.EXAMPLE
    PS> ./Add-SiteDesign.ps1 -Title "Project Site" -WebTemplate "64" -SiteScripts @("guid")
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [string]$WebTemplate,
    [Parameter(Mandatory = $true)]
    [guid[]]$SiteScripts,
    [string]$Description
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Title = $Title; WebTemplate = $WebTemplate; SiteScripts = $SiteScripts }
        if (-not [System.String]::IsNullOrWhiteSpace($Description)) { $cmdArgs.Add('Description', $Description) }
        $result = Add-SPOSiteDesign @cmdArgs | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
