#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits the total number of users in the tenant

.DESCRIPTION
    Retrieves the total count of user objects in the Microsoft Graph tenant. Requires ConsistencyLevel 'eventual' for large tenants.

.EXAMPLE
    PS> ./Get-MgmtGraphUserCount.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $count = Get-MgUserCount -ConsistencyLevel eventual -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            TotalUserCount = $count
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
