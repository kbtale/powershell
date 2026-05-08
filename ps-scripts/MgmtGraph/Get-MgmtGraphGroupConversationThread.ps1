#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group conversation threads

.DESCRIPTION
    Retrieves conversational threads inside a specified group conversation under Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    The unique identifier of the target conversation.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversationThread.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ConversationId
)

Process {
    try {
        $params = @{
            'GroupId'        = $GroupId
            'ConversationId' = $ConversationId
            'All'            = $true
            'ErrorAction'    = 'Stop'
        }

        $threads = Get-MgGroupConversationThread @params
        
        $results = foreach ($t in $threads) {
            [PSCustomObject]@{
                GroupId               = $GroupId
                ConversationId        = $ConversationId
                ThreadId              = $t.Id
                Topic                 = $t.Topic
                Preview               = $t.Preview
                LastDeliveredDateTime = $t.LastDeliveredDateTime
                HasAttachments        = $t.HasAttachments
                IsLocked              = $t.IsLocked
                UniqueSenders         = ($t.UniqueSenders -join "; ")
                Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
