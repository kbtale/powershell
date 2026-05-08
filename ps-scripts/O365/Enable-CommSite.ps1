#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Enables communication site features
.DESCRIPTION
    Enables communication site experience on a SharePoint site.
.PARAMETER SiteUrl
    URL of the site to enable
.EXAMPLE
    PS> ./Enable-CommSite.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/comm"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl
)

Process {
    try {
        $result = Enable-SPOCommSite -SiteUrl $SiteUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
