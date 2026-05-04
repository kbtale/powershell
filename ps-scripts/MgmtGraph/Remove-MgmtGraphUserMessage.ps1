#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Deletes a message from a user's mailbox

.DESCRIPTION
    Removes a specifies message from a user's mailbox in Microsoft Graph. This action is permanent.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MessageId
    Specifies the ID of the message to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphUserMessage.ps1 -Identity "user@example.com" -MessageId "message-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MessageId
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'MessageId'   = $MessageId
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgUserMessage @params
        
        $result = [PSCustomObject]@{
            UserId    = $Identity
            MessageId = $MessageId
            Action    = "MessageRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
