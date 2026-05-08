#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group member counts by type

.DESCRIPTION
    Retrieves the total count of group members, optionally filtered by member types (Applications, Devices, Groups, Contacts, ServicePrincipals, or Users) from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of group members to count. Supported values: AsApplication, AsDevice, AsGroup, AsOrgContact, AsServicePrincipal, AsUser.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberCount.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberCount.ps1 -GroupId "group-id-123" -ResultType AsUser

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
            'GroupId'          = $GroupId
            'ConsistencyLevel' = 'eventual'
            'ErrorAction'      = 'Stop'
        }

        $count = $null

        if ($ResultType) {
            switch ($ResultType) {
                'AsApplication' {
                    $count = Get-MgGroupMemberCountAsApplication @params
                }
                'AsDevice' {
                    $count = Get-MgGroupMemberCountAsDevice @params
                }
                'AsGroup' {
                    $count = Get-MgGroupMemberCountAsGroup @params
                }
                'AsOrgContact' {
                    $count = Get-MgGroupMemberCountAsOrgContact @params
                }
                'AsServicePrincipal' {
                    $count = Get-MgGroupMemberCountAsServicePrincipal @params
                }
                'AsUser' {
                    $count = Get-MgGroupMemberCountAsUser @params
                }
            }
        }
        else {
            $count = Get-MgGroupMemberCount @params
        }

        $result = [PSCustomObject]@{
            GroupId     = $GroupId
            TypeFilter  = if ($ResultType) { $ResultType } else { 'All' }
            MemberCount = $count
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
