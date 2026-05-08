#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of group setting objects

.DESCRIPTION
    Retrieves the total count of group setting objects defined in the tenant or for a specific group in Microsoft Graph.

.PARAMETER GroupId
    Optional. The unique identifier of the Microsoft Graph group to get settings count for.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupSettingCount.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [string]$GroupId
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
            'Headers'     = @{ 'ConsistencyLevel' = 'eventual' }
        }
        if ($GroupId) {
            $params.Add('GroupId', $GroupId)
        }

        $count = Get-MgGroupSettingCount @params
        
        $result = [PSCustomObject]@{
            GroupId      = $GroupId
            SettingCount = $count
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
