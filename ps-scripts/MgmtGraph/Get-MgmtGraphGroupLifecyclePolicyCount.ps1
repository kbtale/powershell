#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the count of group lifecycle policies

.DESCRIPTION
    Retrieves the total count of group lifecycle (expiration) policies defined in Microsoft Graph for the tenant.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupLifecyclePolicyCount.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $count = Get-MgGroupLifecyclePolicyCount -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            LifecyclePolicyCount = $count
            Timestamp            = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
