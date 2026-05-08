#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves accepted senders for a group

.DESCRIPTION
    Retrieves the list of users or groups authorized to post messages or calendar events to the specified unified group.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupAcceptedSender.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $senders = Get-MgGroupAcceptedSender -GroupId $GroupId -All -ErrorAction Stop
        
        $results = foreach ($s in $senders) {
            $displayName = $s.AdditionalProperties['displayName']
            if ($null -eq $displayName) { $displayName = $s.DisplayName }

            $upn = $s.AdditionalProperties['userPrincipalName']
            if ($null -eq $upn) { $upn = $s.Mail }

            $type = $s.AdditionalProperties['@odata.type']
            if ($type) { $type = $type -replace '^#microsoft.graph.', '' }

            [PSCustomObject]@{
                GroupId           = $GroupId
                SenderId          = $s.Id
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
