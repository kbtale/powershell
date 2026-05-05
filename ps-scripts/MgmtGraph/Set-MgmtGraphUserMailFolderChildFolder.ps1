#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Updates child mail folder properties

.DESCRIPTION
    Modifies configuration details for a specifies child folder in a user's mailbox, such as its display name.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the parent mail folder.

.PARAMETER ChildFolderId
    Specifies the ID of the child folder to update.

.PARAMETER DisplayName
    Specifies the new display name for the child folder.

.EXAMPLE
    PS> ./Set-MgmtGraphUserMailFolderChildFolder.ps1 -Identity "user@example.com" -MailFolderId "inbox" -ChildFolderId "sub-id" -DisplayName "Updated Sub"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [Parameter(Mandatory = $true)]
    [string]$ChildFolderId,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'MailFolderId1' = $ChildFolderId
            'DisplayName'  = $DisplayName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        Update-MgUserMailFolderChildFolder @params
        
        $result = [PSCustomObject]@{
            UserId        = $Identity
            ParentId      = $MailFolderId
            ChildFolderId = $ChildFolderId
            DisplayName   = $DisplayName
            Action        = "ChildFolderUpdated"
            Status        = "Success"
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
