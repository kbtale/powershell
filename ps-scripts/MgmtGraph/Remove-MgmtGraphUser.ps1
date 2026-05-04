#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Deletes a Microsoft Graph user account

.DESCRIPTION
    Deletes a specifies user account from the Microsoft Graph tenant. By default, deleted users are moved to the recycle bin and can be restored within 30 days.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to delete.

.EXAMPLE
    PS> ./Remove-MgmtGraphUser.ps1 -Identity "retired.user@example.com"

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

        Remove-MgUser @params
        
        $result = [PSCustomObject]@{
            Identity  = $Identity
            Action    = "UserDeleted"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
