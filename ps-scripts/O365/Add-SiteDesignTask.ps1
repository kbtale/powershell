#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Adds a site design task
.DESCRIPTION
    Creates a site design task for applying site designs to sites.
.PARAMETER SiteDesignId
    Site design ID to apply
.PARAMETER WebUrl
    Target site URL
.EXAMPLE
    PS> ./Add-SiteDesignTask.ps1 -SiteDesignId "guid" -WebUrl "https://contoso.sharepoint.com/sites/project"
.CATEGORY O365
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)][guid]$SiteDesignId,
    [Parameter(Mandatory = $true)][string]$WebUrl
)
Process {
    try {
        $result = Add-SPOSiteDesignTask -SiteDesignId $SiteDesignId -WebUrl $WebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
