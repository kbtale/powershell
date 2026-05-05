#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Deletes a Microsoft Team channel

.DESCRIPTION
    Removes a specifies channel from a Team. This action is permanent.

.PARAMETER Identity
    Specifies the ID of the Team.

.PARAMETER ChannelId
    Specifies the ID of the channel to remove.

.EXAMPLE
    PS> ./Remove-MgmtGraphTeamChannel.ps1 -Identity "team-id" -ChannelId "channel-id"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$ChannelId
)

Process {
    try {
        $params = @{
            'TeamId'      = $Identity
            'ChannelId'   = $ChannelId
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-MgTeamChannel @params
        
        $result = [PSCustomObject]@{
            TeamId    = $Identity
            ChannelId = $ChannelId
            Action    = "ChannelRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
