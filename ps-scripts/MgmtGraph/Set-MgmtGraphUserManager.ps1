#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Updates the manager for a Microsoft Graph user

.DESCRIPTION
    Assigns a specifies user or contact as the manager for a target Microsoft Graph user.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to update.

.PARAMETER ManagerIdentity
    Specifies the UserPrincipalName or ID of the manager to assign.

.EXAMPLE
    PS> ./Set-MgmtGraphUserManager.ps1 -Identity "user@example.com" -ManagerIdentity "manager@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ManagerIdentity
)

Process {
    try {
        $manager = Get-MgUser -UserId $ManagerIdentity -ErrorAction Stop
        
        $params = @{
            'UserId'      = $Identity
            'OdataId'     = "https://graph.microsoft.com/v1.0/users/$($manager.Id)"
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Set-MgUserManagerByRef @params
        
        $result = [PSCustomObject]@{
            UserIdentity    = $Identity
            ManagerIdentity = $ManagerIdentity
            Action          = "UserManagerUpdated"
            Status          = "Success"
            Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
