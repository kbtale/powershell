#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Removes channels from all teams
.DESCRIPTION
    Removes specified channels from all teams in Microsoft Teams. Skips teams that don't have the channel.
.PARAMETER ChannelNames
    One or more channel display names, comma separated
.EXAMPLE
    PS> ./Remove-MSTTeamChannelFromAllTeams.ps1 -ChannelNames "OldChannel1,OldChannel2"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ChannelNames
)

Process {
    try {
        $teams = Get-Team -ErrorAction Stop
        [string[]]$result = @()
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

        foreach ($cnl in $ChannelNames.Split(',')) {
            foreach ($team in $teams) {
                try {
                    $check = Get-TeamChannel -GroupId $team.GroupId -ErrorAction Stop | Where-Object { $_.DisplayName -eq ($cnl.Trim()) }
                    if ($null -ne $check) {
                        $null = Remove-TeamChannel @cmdArgs -GroupId $team.GroupId -DisplayName ($cnl.Trim())
                    }
                    $result += "Channel $($cnl.Trim()) removed from team $($team.DisplayName)"
                }
                catch {
                    $result += "Error removing channel $($cnl.Trim()) from team $($team.DisplayName)"
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
