#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Team membership

.DESCRIPTION
    Retrieves the list of members and owners for a specifies Team, including their roles.

.PARAMETER Identity
    Specifies the ID of the Team to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphTeamMember.ps1 -Identity "team-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $members = Get-MgTeamMember -TeamId $Identity -All -ErrorAction Stop
        
        $results = foreach ($m in $members) {
            [PSCustomObject]@{
                DisplayName = $m.DisplayName
                Roles       = $m.Roles -join ", "
                Id          = $m.Id
                UserId      = $m.AdditionalProperties.userId
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
