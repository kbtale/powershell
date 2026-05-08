#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site design rights
.DESCRIPTION
    Retrieves principal rights for a site design.
.PARAMETER Identity
    Site design ID
.EXAMPLE
    PS> ./Get-SiteDesignRights.ps1 -Identity "guid"
.CATEGORY O365
#>
[CmdletBinding()]
Param([Parameter(Mandatory = $true)][guid]$Identity)
Process {
    try {
        $result = Get-SPOSiteDesignRights -Identity $Identity -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
