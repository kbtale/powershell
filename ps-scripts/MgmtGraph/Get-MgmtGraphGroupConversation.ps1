#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group conversations

.DESCRIPTION
    Retrieves conversational threads and topics for a specified unified group in Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    Optional. The unique identifier of a specific conversation to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversation.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversation.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [string]$ConversationId
)

Process {
    try {
        $params = @{
            'GroupId'     = $GroupId
            'ErrorAction' = 'Stop'
        }

        if ($ConversationId) {
            $params.Add('ConversationId', $ConversationId)
        }
        else {
            $params.Add('All', $true)
        }

        $conversations = Get-MgGroupConversation @params
        
        $results = foreach ($c in $conversations) {
            [PSCustomObject]@{
                GroupId               = $GroupId
                ConversationId        = $c.Id
                Topic                 = $c.Topic
                Preview               = $c.Preview
                LastDeliveredDateTime = $c.LastDeliveredDateTime
                HasAttachments        = $c.HasAttachments
                UniqueSenders         = ($c.UniqueSenders -join "; ")
                Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
