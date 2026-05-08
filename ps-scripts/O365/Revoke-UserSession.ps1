#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Revokes a user's O365 sessions
.DESCRIPTION
    Invalidates a particular user's Office 365 sessions across all their devices.
.PARAMETER User
    User name whose sessions to revoke
.EXAMPLE
    PS> ./Revoke-UserSession.ps1 -User "user@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$User
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; User = $User; Confirm = $false }
        $result = Revoke-SPOUserSession @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}