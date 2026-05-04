#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Removes the manager relationship for a Microsoft Graph user

.DESCRIPTION
    Clears the manager assignment for a specifies Microsoft Graph user account.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user whose manager is to be removed.

.EXAMPLE
    PS> ./Remove-MgmtGraphUserManager.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgUserManagerByRef @params
        
        $result = [PSCustomObject]@{
            UserIdentity = $Identity
            Action       = "UserManagerRemoved"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
