#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets the last log collection time
.DESCRIPTION
    Returns the most recent time when the SharePoint Online organization logs were collected.
.EXAMPLE
    PS> ./Get-TenantLogLastAvailableTimeInUtc.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOTenantLogLastAvailableTimeInUtc -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}