#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Add new channels to all teams
.DESCRIPTION
    Adds one or more channels to all teams in Microsoft Teams.
.PARAMETER ChannelNames
    One or more channel display names, comma separated
.PARAMETER Description
    Channel description
.EXAMPLE
    PS> ./Add-MSTTeamChannelToAllTeams.ps1 -ChannelNames "General,Announcements" -Description "Team channel"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ChannelNames,
    [ValidateLength(0, 1024)]
    [string]$Description
)

Process {
    try {
        $teams = Get-Team -ErrorAction Stop
        [string[]]$result = @()
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
        if ($PSBoundParameters.ContainsKey('Description')) {
            $cmdArgs.Add('Description', $Description)
        }

        foreach ($cnl in $ChannelNames.Split(',')) {
            foreach ($team in $teams) {
                try {
                    $null = New-TeamChannel @cmdArgs -GroupId $team.GroupId -DisplayName ($cnl.Trim())
                    $result += "Channel $($cnl.Trim()) added to team $($team.DisplayName)"
                }
                catch {
                    $result += "Error adding channel $($cnl.Trim()) to team $($team.DisplayName)"
                }
            }
        }

        foreach ($msg in $result) {
            [PSCustomObject]@{
                Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                Result    = $msg
            }
        }
    }
    catch { throw }
}
