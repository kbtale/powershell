#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves posts in a conversation thread

.DESCRIPTION
    Retrieves conversational posts inside a specified conversation thread under Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    The unique identifier of the target conversation.

.PARAMETER ConversationThreadId
    The unique identifier of the target conversation thread.

.PARAMETER PostId
    Optional. The unique identifier of a specific post to retrieve.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversationThreadPost.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456" -ConversationThreadId "thread-id-789"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ConversationId,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]$ConversationThreadId,

    [string]$PostId
)

Process {
    try {
        $params = @{
            'GroupId'              = $GroupId
            'ConversationId'       = $ConversationId
            'ConversationThreadId' = $ConversationThreadId
            'ErrorAction'          = 'Stop'
        }

        if ($PostId) {
            $params.Add('PostId', $PostId)
        }
        else {
            $params.Add('All', $true)
        }

        $posts = Get-MgGroupConversationThreadPost @params
        
        $results = foreach ($p in $posts) {
            [PSCustomObject]@{
                GroupId              = $GroupId
                ConversationId       = $ConversationId
                ConversationThreadId = $ConversationThreadId
                PostId               = $p.Id
                ReceivedDateTime     = $p.ReceivedDateTime
                CreatedDateTime      = $p.CreatedDateTime
                LastModifiedDateTime = $p.LastModifiedDateTime
                HasAttachments       = $p.HasAttachments
                Sender               = $p.Sender.EmailAddress.Address
                SenderName           = $p.Sender.EmailAddress.Name
                BodyPreview          = $p.Body.Content
                Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
