#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Audits Microsoft Team channels

.DESCRIPTION
    Retrieves properties for a specifies channel or lists all channels within a specified Team.

.PARAMETER Identity
    Specifies the ID of the Team to audit.

.PARAMETER ChannelId
    Optional. Specifies the ID of a specific channel to retrieve. If omitted, all channels in the Team are listed.

.EXAMPLE
    PS> ./Get-MgmtGraphTeamChannel.ps1 -Identity "team-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [string]$ChannelId
)

Process {
    try {
        $params = @{
            'TeamId'      = $Identity
            'ErrorAction' = 'Stop'
        }

        if ($ChannelId) {
            $params.Add('ChannelId', $ChannelId)
        }
        else {
            $params.Add('All', $true)
        }

        $channels = Get-MgTeamChannel @params
        
        $results = foreach ($c in $channels) {
            [PSCustomObject]@{
                DisplayName     = $c.DisplayName
                Id              = $c.Id
                Description     = $c.Description
                MembershipType  = $c.MembershipType
                CreatedDateTime = $c.CreatedDateTime
                WebUrl          = $c.WebUrl
                Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
