#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site groups
.DESCRIPTION
    Retrieves groups associated with a site.
.PARAMETER Site
    Site URL
.EXAMPLE
    PS> ./Get-SiteGroup.ps1 -Site "https://contoso.sharepoint.com/sites/project"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][string]$Site)
Process {
    try {
        $result = Get-SPOSiteGroup -Site $Site -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
