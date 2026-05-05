#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Audits user mailbox messages

.DESCRIPTION
    Retrieves properties for a specifies message or lists recent messages in a user's mailbox.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MessageId
    Optional. Specifies the ID of a specific message to retrieve. If omitted, the latest messages are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMessage.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$MessageId
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'ErrorAction' = 'Stop'
        }

        if ($MessageId) {
            $params.Add('MessageId', $MessageId)
        }
        else {
            $params.Add('Top', 50)
        }

        $messages = Get-MgUserMessage @params
        
        $results = foreach ($m in $messages) {
            [PSCustomObject]@{
                Subject          = $m.Subject
                ReceivedDateTime = $m.ReceivedDateTime
                SentDateTime     = $m.SentDateTime
                From             = $m.From.EmailAddress.Address
                Id               = $m.Id
                IsRead           = $m.IsRead
                HasAttachments   = $m.HasAttachments
                Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object ReceivedDateTime -Descending)
    }
    catch {
        throw
    }
}
