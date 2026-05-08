#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site design tasks
.DESCRIPTION
    Retrieves site design tasks for a site.
.PARAMETER WebUrl
    Site URL
.EXAMPLE
    PS> ./Get-SiteDesignTask.ps1 -WebUrl "https://contoso.sharepoint.com/sites/project"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][string]$WebUrl)
Process {
    try {
        $result = Get-SPOSiteDesignTask -WebUrl $WebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
