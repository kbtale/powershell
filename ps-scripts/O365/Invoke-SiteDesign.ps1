#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Invokes a site design
.DESCRIPTION
    Applies a site design task to a site.
.PARAMETER Identity
    Site design ID
.PARAMETER WebUrl
    Target site URL
.EXAMPLE
    PS> ./Invoke-SiteDesign.ps1 -Identity "guid" -WebUrl "https://contoso.sharepoint.com/sites/project"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][guid]$Identity, [Parameter(Mandatory = $true)][string]$WebUrl)
Process {
    try {
        $result = Invoke-SPOSiteDesign -Identity $Identity -WebUrl $WebUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
