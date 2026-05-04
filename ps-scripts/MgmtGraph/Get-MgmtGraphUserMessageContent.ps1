#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Mail

<#
.SYNOPSIS
    MgmtGraph: Retrieves user message content

.DESCRIPTION
    Downloads the raw content of a specifies message in a user's mailbox to a file.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user.

.PARAMETER MessageId
    Specifies the ID of the message to retrieve.

.PARAMETER Path
    Specifies the file path where the message content will be saved.

.EXAMPLE
    PS> ./Get-MgmtGraphUserMessageContent.ps1 -Identity "user@example.com" -MessageId "message-id" -Path "C:\Temp\message.eml"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$MessageId,

    [Parameter(Mandatory = $true)]
    [string]$Path
)

Process {
    try {
        $params = @{
            'UserId'      = $Identity
            'MessageId'   = $MessageId
            'OutFile'     = $Path
            'ErrorAction' = 'Stop'
        }

        Get-MgUserMessageContent @params
        
        $result = [PSCustomObject]@{
            UserId    = $Identity
            MessageId = $MessageId
            SavedPath = $Path
            Action    = "MessageContentExported"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
