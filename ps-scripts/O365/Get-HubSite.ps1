#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets hub sites
.DESCRIPTION
    Retrieves registered hub sites in the tenant.
.EXAMPLE
    PS> ./Get-HubSite.ps1
.CATEGORY O365
#>
Process {
    try {
        $result = Get-SPOHubSite -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
