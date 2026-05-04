#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Updates user mail folder properties

.DESCRIPTION
    Modifies configuration details for a specifies mail folder in a user's mailbox, such as its display name.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the mail folder to update.

.PARAMETER DisplayName
    Specifies the new display name for the mail folder.

.EXAMPLE
    PS> ./Set-MgmtGraphUserMailFolder.ps1 -Identity "user@example.com" -MailFolderId "folder-id" -DisplayName "New Folder Name"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'DisplayName'  = $DisplayName
            'Confirm'      = $false
            'ErrorAction'  = 'Stop'
        }

        Update-MgUserMailFolder @params
        
        $result = [PSCustomObject]@{
            UserId       = $Identity
            MailFolderId = $MailFolderId
            DisplayName  = $DisplayName
            Action       = "MailFolderUpdated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
