#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets org news site
.DESCRIPTION
    Returns the organization news site configuration.
.EXAMPLE
    PS> ./Get-OrgNewsSite.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOOrgNewsSite -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
