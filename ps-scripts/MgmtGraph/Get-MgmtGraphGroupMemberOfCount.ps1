#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of parent containers for a group

.DESCRIPTION
    Retrieves the total count of parent groups or administrative units that a specified group belongs to directly in Microsoft Graph, with optional type filtering.

.PARAMETER GroupId
    The unique identifier of the child Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of parent container to count. Supported values: AsAdministrativeUnit, AsGroup.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberOfCount.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberOfCount.ps1 -GroupId "group-id-123" -ResultType AsGroup

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [ValidateSet('AsAdministrativeUnit', 'AsGroup')]
    [string]$ResultType
)

Process {
    try {
        $params = @{
            'GroupId'          = $GroupId
            'ConsistencyLevel' = 'eventual'
            'ErrorAction'      = 'Stop'
        }

        $count = $null

        if ($ResultType) {
            switch ($ResultType) {
                'AsAdministrativeUnit' {
                    $count = Get-MgGroupMemberOfCountAsAdministrativeUnit @params
                }
                'AsGroup' {
                    $count = Get-MgGroupMemberOfCountAsGroup @params
                }
            }
        }
        else {
            $count = Get-MgGroupMemberOfCount @params
        }

        $result = [PSCustomObject]@{
            GroupId       = $GroupId
            TypeFilter    = if ($ResultType) { $ResultType } else { 'All' }
            MemberOfCount = $count
            Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
