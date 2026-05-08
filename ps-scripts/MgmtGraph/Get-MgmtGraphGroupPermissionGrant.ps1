#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group permission grants

.DESCRIPTION
    Retrieves the collection of resource-specific permission grants defined on a specified Microsoft Graph group.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupPermissionGrant.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $grants = Get-MgGroupPermissionGrant -GroupId $GroupId -All -ErrorAction Stop
        
        $results = foreach ($g in $grants) {
            [PSCustomObject]@{
                GroupId       = $GroupId
                GrantId       = $g.Id
                Permission    = $g.Permission
                PrincipalId   = $g.PrincipalId
                ClientAppId   = $g.ClientId
                Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
