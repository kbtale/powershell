#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets sync client restriction config
.DESCRIPTION
    Returns the current tenant-wide sync client restriction configuration.
.EXAMPLE
    PS> ./Get-TenantSyncClientRestriction.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOTenantSyncClientRestriction -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}