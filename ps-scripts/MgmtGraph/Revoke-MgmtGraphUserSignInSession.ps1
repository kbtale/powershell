#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users.Actions

<#
.SYNOPSIS
    MgmtGraph: Revokes all active sign-in sessions for a Microsoft Graph user

.DESCRIPTION
    Invalidates all refresh tokens issued to applications for a specifies user. This effectively logs the user out of all sessions and devices.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to revoke sessions for.

.EXAMPLE
    PS> ./Revoke-MgmtGraphUserSignInSession.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $status = Revoke-MgUserSignInSession -UserId $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            UserIdentity = $Identity
            Action       = "SignInSessionsRevoked"
            Status       = $status
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
