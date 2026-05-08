#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets hide default themes setting
.DESCRIPTION
    Returns the hide default themes configuration setting.
.EXAMPLE
    PS> ./Get-HideDefaultThemes.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOHideDefaultThemes -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
