#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Groups

<#
.SYNOPSIS
    MgmtGraph: Retrieves all SharePoint sites associated with a group

.DESCRIPTION
    Retrieves the SharePoint sites linked to a specified Microsoft Graph group (e.g., Teams group or unified group).

.PARAMETER GroupId
    The unique identifier of the Microsoft Graph group.

.EXAMPLE
    PS> ./Get-MgmtGraphAllGroupSite.ps1 -GroupId "group-id-123"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$GroupId
)

Process {
    try {
        $sites = Get-MgAllGroupSite -GroupId $GroupId -ErrorAction Stop
        
        $results = foreach ($s in $sites) {
            [PSCustomObject]@{
                GroupId     = $GroupId
                SiteId      = $s.Id
                DisplayName = $s.DisplayName
                Name        = $s.Name
                WebUrl      = $s.WebUrl
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
