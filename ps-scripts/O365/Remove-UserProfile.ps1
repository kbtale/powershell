#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a user profile
.DESCRIPTION
    Removes a user profile from the tenant.
.PARAMETER LoginName
    Login name of the user whose profile is to be deleted
.EXAMPLE
    PS> ./Remove-UserProfile.ps1 -LoginName "user@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$LoginName
)

Process {
    try {
        $result = Remove-SPOUserProfile -LoginName $LoginName -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}