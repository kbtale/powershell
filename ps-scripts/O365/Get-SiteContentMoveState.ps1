#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site content move state
.DESCRIPTION
    Returns the content move state for a site.
.PARAMETER SourceSiteUrl
    Source site URL
.EXAMPLE
    PS> ./Get-SiteContentMoveState.ps1 -SourceSiteUrl "https://contoso.sharepoint.com/sites/source"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][string]$SourceSiteUrl)
Process {
    try {
        $result = Get-SPOSiteContentMoveState -SourceSiteUrl $SourceSiteUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
