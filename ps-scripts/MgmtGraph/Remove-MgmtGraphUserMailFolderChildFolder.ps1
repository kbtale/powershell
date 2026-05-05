#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Deletes a child mail folder

.DESCRIPTION
    Removes a specifies child mail folder from a parent folder in a user's mailbox. This action is permanent.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the parent mail folder.

.PARAMETER ChildFolderId
    Specifies the ID of the child folder to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphUserMailFolderChildFolder.ps1 -Identity "user@example.com" -MailFolderId "inbox" -ChildFolderId "sub-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [Parameter(Mandatory = $true)]
    [string]$ChildFolderId
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'MailFolderId1' = $ChildFolderId
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        Remove-MgUserMailFolderChildFolder @params
        
        $result = [PSCustomObject]@{
            UserId        = $Identity
            ParentId      = $MailFolderId
            ChildFolderId = $ChildFolderId
            Action        = "ChildFolderRemoved"
            Status        = "Success"
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
