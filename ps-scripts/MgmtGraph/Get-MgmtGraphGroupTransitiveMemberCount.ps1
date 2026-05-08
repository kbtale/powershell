#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves transitive group member counts

.DESCRIPTION
    Retrieves the total count of direct and transitive members of a group from Microsoft Graph, optionally filtered by member types.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of transitive members to count. Supported values: AsApplication, AsDevice, AsGroup, AsOrgContact, AsServicePrincipal, AsUser.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMemberCount.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMemberCount.ps1 -GroupId "group-id-123" -ResultType AsUser

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [ValidateSet('AsApplication', 'AsDevice', 'AsGroup', 'AsOrgContact', 'AsServicePrincipal', 'AsUser')]
    [string]$ResultType
)

Process {
    try {
        $params = @{
            'GroupId'     = $GroupId
            'All'         = $true
            'ErrorAction' = 'Stop'
        }

        $count = $null

        if ($ResultType) {
            switch ($ResultType) {
                'AsApplication' {
                    $count = Get-MgGroupTransitiveMemberCountAsApplication @params
                }
                'AsDevice' {
                    $count = Get-MgGroupTransitiveMemberCountAsDevice @params
                }
                'AsGroup' {
                    $count = Get-MgGroupTransitiveMemberCountAsGroup @params
                }
                'AsOrgContact' {
                    $count = Get-MgGroupTransitiveMemberCountAsOrgContact @params
                }
                'AsServicePrincipal' {
                    $count = Get-MgGroupTransitiveMemberCountAsServicePrincipal @params
                }
                'AsUser' {
                    $count = Get-MgGroupTransitiveMemberCountAsUser @params
                }
            }
        }
        else {
            $count = Get-MgGroupTransitiveMemberCount @params
        }

        $result = [PSCustomObject]@{
            GroupId               = $GroupId
            TypeFilter            = if ($ResultType) { $ResultType } else { 'All' }
            TransitiveMemberCount = $count
            Timestamp             = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
