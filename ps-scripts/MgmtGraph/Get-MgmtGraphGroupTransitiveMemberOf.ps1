#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves groups that a group is a transitive member of

.DESCRIPTION
    Retrieves the parent groups or administrative units that a specified group belongs to, either directly or via nested memberships, from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the child Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of parent container to retrieve. Supported values: AsAdministrativeUnit, AsGroup.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMemberOf.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMemberOf.ps1 -GroupId "group-id-123" -ResultType AsGroup

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
            'GroupId'     = $GroupId
            'All'         = $true
            'ErrorAction' = 'Stop'
        }

        $containers = $null

        if ($ResultType) {
            switch ($ResultType) {
                'AsAdministrativeUnit' {
                    $containers = Get-MgGroupTransitiveMemberOfAsAdministrativeUnit @params
                }
                'AsGroup' {
                    $containers = Get-MgGroupTransitiveMemberOfAsGroup @params
                }
            }
        }
        else {
            $containers = Get-MgGroupTransitiveMemberOf @params
        }

        $results = foreach ($c in $containers) {
            $displayName = $c.AdditionalProperties['displayName']
            if ($null -eq $displayName) { $displayName = $c.DisplayName }

            $description = $c.AdditionalProperties['description']
            if ($null -eq $description) { $description = $c.Description }

            $type = $ResultType
            if (-not $type) { $type = $c.AdditionalProperties['@odata.type'] -replace '^#microsoft.graph.', '' }

            [PSCustomObject]@{
                GroupId     = $GroupId
                ParentId    = $c.Id
                DisplayName = $displayName
                Description = $description
                Type        = $type
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
