#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes user info
.DESCRIPTION
    Removes a user from the user information list of a specific site collection.
.PARAMETER LoginName
    Login name of the user to remove
.PARAMETER Site
    URL of the site collection
.EXAMPLE
    PS> ./Remove-UserInfo.ps1 -LoginName "user@contoso.com" -Site "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$LoginName,
    [string]$Site
)

Process {
    try {
        $result = Remove-SPOUserInfo -LoginName $LoginName -Site $Site -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}