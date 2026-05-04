#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Manages archive actions for a Microsoft Team

.DESCRIPTION
    Archives or unarchives a specifies Microsoft Team. Archiving makes the team read-only for members.

.PARAMETER Identity
    Specifies the ID of the Team.

.PARAMETER Archive
    Specifies whether to archive ($true) or unarchive ($false) the Team.

.EXAMPLE
    PS> ./Invoke-MgmtGraphTeamArchiveAction.ps1 -Identity "team-id" -Archive $true

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [bool]$Archive
)

Process {
    try {
        $params = @{
            'TeamId'      = $Identity
            'ErrorAction' = 'Stop'
        }

        if ($Archive) {
            Invoke-MgArchiveTeam @params
        }
        else {
            Invoke-MgUnarchiveTeam @params
        }
        
        $result = [PSCustomObject]@{
            TeamId    = $Identity
            Action    = if ($Archive) { "TeamArchived" } else { "TeamUnarchived" }
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
