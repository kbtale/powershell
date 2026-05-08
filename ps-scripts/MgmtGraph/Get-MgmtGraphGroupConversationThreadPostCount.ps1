#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of posts in a conversation thread

.DESCRIPTION
    Retrieves the total count of conversational posts within a specified conversation thread under Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    The unique identifier of the target conversation.

.PARAMETER ConversationThreadId
    The unique identifier of the target conversation thread.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversationThreadPostCount.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456" -ConversationThreadId "thread-id-789"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ConversationId,

    [Parameter(Mandatory = $true, Position = 2)]
    [string]$ConversationThreadId
)

Process {
    try {
        $params = @{
            'GroupId'              = $GroupId
            'ConversationId'       = $ConversationId
            'ConversationThreadId' = $ConversationThreadId
            'ErrorAction'          = 'Stop'
        }

        $count = Get-MgGroupConversationThreadPostCount @params
        
        $result = [PSCustomObject]@{
            GroupId              = $GroupId
            ConversationId       = $ConversationId
            ConversationThreadId = $ConversationThreadId
            PostCount            = $count
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
