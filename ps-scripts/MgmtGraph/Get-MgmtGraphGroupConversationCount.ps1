#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of conversations in a group

.DESCRIPTION
    Retrieves the total count of conversation items associated with a specified unified group in Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupConversationCount.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $count = Get-MgGroupConversationCount -GroupId $GroupId -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupId           = $GroupId
            ConversationCount = $count
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
