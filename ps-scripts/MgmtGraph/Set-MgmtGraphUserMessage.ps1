#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Updates user mailbox message properties

.DESCRIPTION
    Modifies properties for a specifies message in a user's mailbox, such as its subject or categories.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MessageId
    Specifies the ID of the message to update.

.PARAMETER Subject
    Optional. Specifies the new subject for the message.

.PARAMETER IsRead
    Optional. Specifies whether the message should be marked as read ($true) or unread ($false).

.PARAMETER Categories
    Optional. Specifies the new array of categories for the message.

.EXAMPLE
    PS> ./Set-MgmtGraphUserMessage.ps1 -Identity "user@example.com" -MessageId "message-id" -IsRead $true

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MessageId,

    [string]$Subject,

    [bool]$IsRead,

    [string[]]$Categories
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'MessageId'   = $MessageId
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($PSBoundParameters.ContainsKey('Subject')) { $params.Add('Subject', $Subject) }
        if ($PSBoundParameters.ContainsKey('IsRead')) { $params.Add('IsRead', $IsRead) }
        if ($PSBoundParameters.ContainsKey('Categories')) { $params.Add('Categories', $Categories) }

        if ($params.Count -gt 4) {
            Update-MgUserMessage @params
            
            $result = [PSCustomObject]@{
                UserId    = $Identity
                MessageId = $MessageId
                Action    = "MessageUpdated"
                Status    = "Success"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            Write-Output $result
        }
        else {
            Write-Warning "No properties specified to update for message."
        }
    }
    catch {
        throw
    }
}
