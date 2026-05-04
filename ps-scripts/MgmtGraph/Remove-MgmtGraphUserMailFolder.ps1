#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Deletes a mail folder from a user's mailbox

.DESCRIPTION
    Removes a specifies mail folder from a user's mailbox in Microsoft Graph. This action is permanent.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the mail folder to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphUserMailFolder.ps1 -Identity "user@example.com" -MailFolderId "folder-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        Remove-MgUserMailFolder @params
        
        $result = [PSCustomObject]@{
            UserId       = $Identity
            MailFolderId = $MailFolderId
            Action       = "MailFolderRemoved"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
