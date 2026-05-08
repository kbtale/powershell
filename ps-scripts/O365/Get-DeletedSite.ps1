#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets deleted sites
.DESCRIPTION
    Retrieves sites in the recycle bin.
.EXAMPLE
    PS> ./Get-DeletedSite.ps1
.CATEGORY O365
#>
Process {
    try {
        $result = Get-SPODeletedSite -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
