#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits the manager of a Microsoft Graph user

.DESCRIPTION
    Retrieves the identity and contact details of the user or contact specifies as the manager for the target Microsoft Graph user.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user whose manager is to be retrieved.

.EXAMPLE
    PS> ./Get-MgmtGraphUserManager.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $manager = Get-MgUserManager -UserId $Identity -ErrorAction Stop
        
        if ($manager) {
            $managerDetails = Get-MgUser -UserId $manager.Id -Property @('DisplayName', 'Id', 'UserPrincipalName', 'Mail', 'JobTitle', 'Department') -ErrorAction Stop
            
            $result = [PSCustomObject]@{
                UserIdentity      = $Identity
                ManagerDisplayName = $managerDetails.DisplayName
                ManagerUPN         = $managerDetails.UserPrincipalName
                ManagerId          = $managerDetails.Id
                ManagerMail        = $managerDetails.Mail
                ManagerJobTitle    = $managerDetails.JobTitle
                Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No manager assigned for user '$Identity'."
        }
    }
    catch {
        throw
    }
}
