#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Retrieves app info
.DESCRIPTION
    Returns information about SharePoint Online apps.
.EXAMPLE
    PS> ./Get-AppInfo.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOAppInfo -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
