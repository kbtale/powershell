#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves group owner counts by type

.DESCRIPTION
    Retrieves the total count of group owners, optionally filtered by owner types (Applications, Devices, Groups, Contacts, ServicePrincipals, or Users) from Microsoft Graph.

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.PARAMETER ResultType
    Optional. The type of group owners to count. Supported values: AsApplication, AsDevice, AsGroup, AsOrgContact, AsServicePrincipal, AsUser.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupOwnerCount.ps1 -GroupId "group-id-123"

.EXAMPLE
    PS> ./Get-MgmtGraphGroupOwnerCount.ps1 -GroupId "group-id-123" -ResultType AsUser

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
                    $count = Get-MgGroupOwnerCountAsApplication @params
                }
                'AsDevice' {
                    $count = Get-MgGroupOwnerCountAsDevice @params
                }
                'AsGroup' {
                    $count = Get-MgGroupOwnerCountAsGroup @params
                }
                'AsOrgContact' {
                    $count = Get-MgGroupOwnerCountAsOrgContact @params
                }
                'AsServicePrincipal' {
                    $count = Get-MgGroupOwnerCountAsServicePrincipal @params
                }
                'AsUser' {
                    $count = Get-MgGroupOwnerCountAsUser @params
                }
            }
        }
        else {
            $count = Get-MgGroupOwnerCount @params
        }

        $result = [PSCustomObject]@{
            GroupId    = $GroupId
            TypeFilter = if ($ResultType) { $ResultType } else { 'All' }
            OwnerCount = $count
            Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
