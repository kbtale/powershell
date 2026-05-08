#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site design run status
.DESCRIPTION
    Retrieves status for a site design task execution.
.PARAMETER RunId
    Run identifier
.PARAMETER WebUrl
    Site URL
.EXAMPLE
    PS> ./Get-SiteDesignRunStatus.ps1 -RunId "guid" -WebUrl "https://contoso.sharepoint.com/sites/project"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][guid]$RunId, [Parameter(Mandatory = $true)][string]$WebUrl)
Process {
    try {
        $result = Get-SPOSiteDesignRunStatus -RunId $RunId -WebUrl $WebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
