#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves transitive parent count for a group

.DESCRIPTION
    Retrieves the total count of parent groups or administrative units that a specified group belongs to transitively (directly or via nested relationships) from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the child Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of parent container to count. Supported values: AsAdministrativeUnit, AsGroup.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMemberOfCount.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMemberOfCount.ps1 -GroupId "group-id-123" -ResultType AsGroup

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
                    $count = Get-MgGroupTransitiveMemberOfCountAsAdministrativeUnit @params
                }
                'AsGroup' {
                    $count = Get-MgGroupTransitiveMemberOfCountAsGroup @params
                }
            }
        }
        else {
            $count = Get-MgGroupTransitiveMemberOfCount @params
        }

        $result = [PSCustomObject]@{
            GroupId                 = $GroupId
            TypeFilter              = if ($ResultType) { $ResultType } else { 'All' }
            TransitiveMemberOfCount = $count
            Timestamp               = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
