#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes sync client restriction
.DESCRIPTION
    Disables the tenant-wide sync client restriction feature.
.EXAMPLE
    PS> ./Remove-TenantSyncClientRestriction.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Remove-SPOTenantSyncClientRestriction -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}