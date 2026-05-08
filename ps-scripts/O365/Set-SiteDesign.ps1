#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Updates a site design
.DESCRIPTION
    Modifies a previously uploaded site design with new property values.
.PARAMETER Identity
    The site design ID
.PARAMETER Title
    Display name of the site design
.PARAMETER WebTemplate
    Base template: Team site template or Communication site template
.PARAMETER Description
    Display description of the site design
.PARAMETER IsDefault
    Apply the site design to the default site template
.PARAMETER PreviewImageAltText
    Alt text description of the preview image
.PARAMETER PreviewImageUrl
    URL of a preview image
.EXAMPLE
    PS> ./Set-SiteDesign.ps1 -Identity "db752673-18fd-44db-865a-aa3e0b28698e" -Title "Updated Design"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [string]$Title,
    [ValidateSet('Team site template','Communication site template')]
    [string]$WebTemplate,
    [string]$Description,
    [switch]$IsDefault,
    [string]$PreviewImageAltText,
    [string]$PreviewImageUrl
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity }
        if ($WebTemplate -eq 'Team site template') { $cmdArgs.Add('WebTemplate', '64') }
        elseif ($WebTemplate -eq 'Communication site template') { $cmdArgs.Add('WebTemplate', '68') }
        if ($PSBoundParameters.ContainsKey('Title')) { $cmdArgs.Add('Title', $Title) }
        if ($PSBoundParameters.ContainsKey('Description')) { $cmdArgs.Add('Description', $Description) }
        if ($PSBoundParameters.ContainsKey('IsDefault')) { $cmdArgs.Add('IsDefault', $IsDefault) }
        if ($PSBoundParameters.ContainsKey('PreviewImageAltText')) { $cmdArgs.Add('PreviewImageAltText', $PreviewImageAltText) }
        if ($PSBoundParameters.ContainsKey('PreviewImageUrl')) { $cmdArgs.Add('PreviewImageUrl', $PreviewImageUrl) }
        $result = Set-SPOSiteDesign @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}