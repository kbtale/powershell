#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits messages within a specific user mail folder

.DESCRIPTION
    Retrieves properties for a specifies message or lists recent messages within a specifies mail folder in a user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MailFolderId
    Specifies the ID of the mail folder to audit.

.PARAMETER MessageId
    Optional. Specifies the ID of a specific message to retrieve. If omitted, the latest messages in the folder are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMailFolderMessage.ps1 -Identity "user@example.com" -MailFolderId "inbox"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MailFolderId,

    [string]$MessageId
)

Process {
    try {
        $params = @{
            'UserId'       = $Identity
            'MailFolderId' = $MailFolderId
            'ErrorAction'  = 'Stop'
        }

        if ($MessageId) {
            $params.Add('MessageId', $MessageId)
        }
        else {
            $params.Add('Top', 50)
        }

        $messages = Get-MgUserMailFolderMessage @params
        
        $results = foreach ($m in $messages) {
            [PSCustomObject]@{
                Subject          = $m.Subject
                ReceivedDateTime = $m.ReceivedDateTime
                SentDateTime     = $m.SentDateTime
                From             = $m.From.EmailAddress.Address
                Id               = $m.Id
                IsRead           = $m.IsRead
                Categories       = $m.Categories -join ", "
                Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object ReceivedDateTime -Descending)
    }
    catch {
        throw
    }
}
