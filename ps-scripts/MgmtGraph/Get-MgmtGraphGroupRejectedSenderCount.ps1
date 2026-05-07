#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of rejected senders for a group

.DESCRIPTION
    Retrieves the total count of users or groups that are not allowed to post messages or calendar events to the specified group from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupRejectedSenderCount.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $count = Get-MgGroupRejectedSenderCount -GroupId $GroupId -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupId             = $GroupId
            RejectedSenderCount = $count
            Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
