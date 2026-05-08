#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves posts inside a conversation thread

.DESCRIPTION
    Retrieves the individual post entities within a specifies conversation thread in a unified group from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ConversationId
    The unique identifier of the conversation.

.PARAMETER ConversationThreadId
    The unique identifier of the conversation thread.

.PARAMETER Properties
    Optional. List of properties to select. Default includes Id, CreatedDateTime, ReceivedDateTime, LastModifiedDateTime, HasAttachments.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupThreadPost.ps1 -GroupId "group-id-123" -ConversationId "conv-id-456" -ConversationThreadId "thread-id-789"

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

    [ValidateSet('ReceivedDateTime', 'Id', 'CreatedDateTime', 'HasAttachments', 'Attachments', 'LastModifiedDateTime', 'MultiValueExtendedProperties', 'Extensions', 'ChangeKey', 'Categories')]
    [string[]]$Properties = @('Id', 'CreatedDateTime', 'ReceivedDateTime', 'LastModifiedDateTime', 'HasAttachments')
)

Process {
    try {
        $posts = Get-MgGroupThreadPost -GroupId $GroupId -ConversationId $ConversationId -ConversationThreadId $ConversationThreadId -All -ErrorAction Stop
        
        $results = foreach ($p in $posts) {
            $obj = [PSCustomObject]@{
                GroupId              = $GroupId
                ConversationId       = $ConversationId
                ConversationThreadId = $ConversationThreadId
                Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            foreach ($prop in $Properties) {
                $obj | Add-Member -MemberType NoteProperty -Name $prop -Value $p.$prop -Force
            }
            $obj
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
