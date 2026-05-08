#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves rejected senders for a group

.DESCRIPTION
    Retrieves the list of users or groups that are not allowed to post messages or calendar events to the specified group from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupRejectedSender.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $senders = Get-MgGroupRejectedSender -GroupId $GroupId -All -ErrorAction Stop
        
        $results = foreach ($r in $senders) {
            $displayName = $r.AdditionalProperties['displayName']
            if ($null -eq $displayName) { $displayName = $r.DisplayName }

            $upn = $r.AdditionalProperties['userPrincipalName']
            if ($null -eq $upn) { $upn = $r.Mail }

            $type = $r.AdditionalProperties['@odata.type']
            if ($type) { $type = $type -replace '^#microsoft.graph.', '' }

            [PSCustomObject]@{
                GroupId           = $GroupId
                SenderId          = $r.Id
                DisplayName       = $displayName
                UserPrincipalName = $upn
                Type              = $type
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
