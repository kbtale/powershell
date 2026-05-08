#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets themes
.DESCRIPTION
    Returns the custom themes defined in the tenant.
.EXAMPLE
    PS> ./Get-Theme.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOTheme -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
