#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves conversation threads inside a group conversation

.DESCRIPTION
    Retrieves the conversation threads belonging to a specified conversation in a unified group from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    The unique identifier of the conversation.

.PARAMETER Properties
    Optional. List of properties to select. Default includes Preview, Topic, Id, LastDeliveredDateTime, HasAttachments, IsLocked.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupThread.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$ConversationId,

    [ValidateSet('Preview', 'Id', 'LastDeliveredDateTime', 'IsLocked', 'HasAttachments', 'UniqueSenders', 'Topic', 'Posts', 'CcRecipients', 'ToRecipients')]
    [string[]]$Properties = @('Preview', 'Topic', 'Id', 'LastDeliveredDateTime', 'HasAttachments', 'IsLocked')
)

Process {
    try {
        $threads = Get-MgGroupThread -GroupId $GroupId -ConversationId $ConversationId -All -ErrorAction Stop
        
        $results = foreach ($t in $threads) {
            $obj = [PSCustomObject]@{
                GroupId        = $GroupId
                ConversationId = $ConversationId
                Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            foreach ($p in $Properties) {
                $obj | Add-Member -MemberType NoteProperty -Name $p -Value $t.$p -Force
            }
            $obj
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
