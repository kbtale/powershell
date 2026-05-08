#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of threads in a conversation

.DESCRIPTION
    Retrieves the total count of conversational threads within a specified group conversation under Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    The unique identifier of the target conversation.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversationThreadCount.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456"

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
            'ErrorAction'    = 'Stop'
        }

        $count = Get-MgGroupConversationThreadCount @params
        
        $result = [PSCustomObject]@{
            GroupId               = $GroupId
            ConversationId        = $ConversationId
            ConversationThreadCount = $count
            Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
