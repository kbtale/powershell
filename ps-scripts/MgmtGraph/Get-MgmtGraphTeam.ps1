#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Teams

.DESCRIPTION
    Retrieves properties for a specifies Team or lists all Teams in the tenant.

.PARAMETER Identity
    Optional. Specifies the ID of the Team to retrieve. If omitted, all Teams are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphTeam.ps1 -Identity "team-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [string]$Identity
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Identity) {
            $params.Add('TeamId', $Identity)
            $teams = Get-MgTeam @params
        }
        else {
            $params.Add('All', $true)
            $teams = Get-MgTeam @params
        }

        $results = foreach ($t in $teams) {
            [PSCustomObject]@{
                DisplayName     = $t.DisplayName
                Id              = $t.Id
                Description     = $t.Description
                Visibility      = $t.Visibility
                IsArchived      = $t.IsArchived
                CreatedDateTime = $t.CreatedDateTime
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
