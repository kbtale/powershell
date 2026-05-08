#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves groups that a specifies group is a member of

.DESCRIPTION
    Retrieves the unique identifiers of the groups that the specifies group is a direct or nested member of, with optional security filtering.

.PARAMETER GroupId
    The unique identifier of the child Microsoft Graph group.

.PARAMETER SecurityEnabledOnly
    Optional. If set to $true, returns only security-enabled groups. If $false, returns all groups.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberGroup.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberGroup.ps1 -GroupId "group-id-123" -SecurityEnabledOnly $true

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId,

    [bool]$SecurityEnabledOnly = $false
)

Process {
    try {
        $params = @{
            'GroupId'             = $GroupId
            'SecurityEnabledOnly' = $SecurityEnabledOnly
            'ErrorAction'         = 'Stop'
        }

        $groupIds = Get-MgGroupMemberGroup @params
        
        $results = foreach ($id in $groupIds) {
            [PSCustomObject]@{
                SourceGroupId = $GroupId
                MemberOfGroupId = $id
                Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
