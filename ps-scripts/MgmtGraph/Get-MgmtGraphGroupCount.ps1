#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves the total count of groups in the tenant

.DESCRIPTION
    Retrieves the aggregate count of all groups in the tenant from Microsoft Graph.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupCount.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $count = Get-MgGroupCount -ConsistencyLevel eventual -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            GroupCount = $count
            Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
