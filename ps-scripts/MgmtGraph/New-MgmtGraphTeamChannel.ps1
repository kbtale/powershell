#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Teams

<#
.SYNOPSIS
    MgmtGraph: Provisions a new Microsoft Team channel

.DESCRIPTION
    Creates a new channel within a specifies Team. Supports standard and private channel creation (if parameters are extended, currently standard).

.PARAMETER Identity
    Specifies the ID of the Team where the channel will be created.

.PARAMETER DisplayName
    Specifies the display name for the new channel.

.PARAMETER Description
    Optional. Specifies a description for the channel.

.PARAMETER FavoriteByDefault
    Optional. If set to $true, the channel will be automatically marked as favorite for all team members.

.EXAMPLE
    PS> ./New-MgmtGraphTeamChannel.ps1 -Identity "team-id" -DisplayName "Project Alpha"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [string]$Description,

    [switch]$FavoriteByDefault
)

Process {
    try {
        $params = @{
            'TeamId'      = $Identity
            'DisplayName' = $DisplayName
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        if ($Description) { $params.Add('Description', $Description) }
        if ($FavoriteByDefault) { $params.Add('IsFavoriteByDefault', $true) }

        $channel = New-MgTeamChannel @params
        
        $result = [PSCustomObject]@{
            TeamId      = $Identity
            DisplayName = $DisplayName
            Id          = $channel.Id
            Status      = "ChannelCreated"
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
