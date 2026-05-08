#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves parent directory object IDs for a group

.DESCRIPTION
    Retrieves the unique identifiers of the parent directory objects (groups, administrative units, etc.) that the specifies group belongs to.

.PARAMETER GroupId
    The unique identifier of the child Microsoft Graph group.

.PARAMETER SecurityEnabledOnly
    Optional. If set to $true, returns only security-enabled parent directory objects. If $false, returns all objects.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberObject.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupMemberObject.ps1 -GroupId "group-id-123" -SecurityEnabledOnly $true

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

        $objectIds = Get-MgGroupMemberObject @params
        
        $results = foreach ($id in $objectIds) {
            [PSCustomObject]@{
                SourceGroupId  = $GroupId
                MemberOfObjectId = $id
                Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
