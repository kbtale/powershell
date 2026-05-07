#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves transitive group members

.DESCRIPTION
    Retrieves the direct and transitive (nested) members of a group from Microsoft Graph, with optional type filtering.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of transitive members to retrieve. Supported values: AsApplication, AsDevice, AsGroup, AsOrgContact, AsServicePrincipal, AsUser.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMember.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupTransitiveMember.ps1 -GroupId "group-id-123" -ResultType AsUser

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

        $members = $null

        if ($ResultType) {
            switch ($ResultType) {
                'AsApplication' {
                    $members = Get-MgGroupTransitiveMemberAsApplication @params
                }
                'AsDevice' {
                    $members = Get-MgGroupTransitiveMemberAsDevice @params
                }
                'AsGroup' {
                    $members = Get-MgGroupTransitiveMemberAsGroup @params
                }
                'AsOrgContact' {
                    $members = Get-MgGroupTransitiveMemberAsOrgContact @params
                }
                'AsServicePrincipal' {
                    $members = Get-MgGroupTransitiveMemberAsServicePrincipal @params
                }
                'AsUser' {
                    $members = Get-MgGroupTransitiveMemberAsUser @params
                }
            }
        }
        else {
            $members = Get-MgGroupTransitiveMember @params
        }

        $results = foreach ($m in $members) {
            $displayName = $m.AdditionalProperties['displayName']
            if ($null -eq $displayName) { $displayName = $m.DisplayName }

            $upn = $m.AdditionalProperties['userPrincipalName']
            if ($null -eq $upn) { $upn = $m.Mail }

            $type = $ResultType
            if (-not $type) { $type = $m.AdditionalProperties['@odata.type'] -replace '^#microsoft.graph.', '' }

            [PSCustomObject]@{
                GroupId           = $GroupId
                MemberId          = $m.Id
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
