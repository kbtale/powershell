#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site design run
.DESCRIPTION
    Retrieves site design execution history for a site.
.PARAMETER WebUrl
    Site URL
.EXAMPLE
    PS> ./Get-SiteDesignRun.ps1 -WebUrl "https://contoso.sharepoint.com/sites/project"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][string]$WebUrl)
Process {
    try {
        $result = Get-SPOSiteDesignRun -WebUrl $WebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
