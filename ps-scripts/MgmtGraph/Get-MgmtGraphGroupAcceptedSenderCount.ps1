#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of accepted senders for a group

.DESCRIPTION
    Retrieves the total count of users or groups authorized to post messages or calendar events to the specified unified group.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupAcceptedSenderCount.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $count = Get-MgGroupAcceptedSenderCount -GroupId $GroupId -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupId             = $GroupId
            AcceptedSenderCount = $count
            Timestamp           = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
