#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets org assets library
.DESCRIPTION
    Returns the organization assets libraries.
.EXAMPLE
    PS> ./Get-OrgAssetsLibrary.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOOrgAssetsLibrary -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
