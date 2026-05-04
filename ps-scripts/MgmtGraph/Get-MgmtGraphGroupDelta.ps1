#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Audits incremental changes to Microsoft Graph groups

.DESCRIPTION
    Retrieves the list of groups that have been created, updated, or deleted since the last delta request. Useful for synchronizing external systems with Microsoft Graph.

.EXAMPLE
    PS> ./Get-MgmtGraphGroupDelta.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $delta = Get-MgGroupDelta -All -ErrorAction Stop
        
        $results = foreach ($g in $delta) {
            [PSCustomObject]@{
                DisplayName     = $g.DisplayName
                Id              = $g.Id
                DeletedDateTime = $g.DeletedDateTime
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
