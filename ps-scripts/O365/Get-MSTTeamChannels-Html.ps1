#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of channels for all teams
.DESCRIPTION
    Generates an HTML report with all or specific channels across all teams.
.PARAMETER Channel
    Specify a channel name to filter (supports wildcard matching)
.EXAMPLE
    PS> ./Get-MSTTeamChannels-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTTeamChannels-Html.ps1 -Channel "General" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$Channel
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}
        $teams = Get-Team @getArgs | Sort-Object DisplayName
        $result = @()

        foreach ($team in $teams) {
            Get-TeamChannel -GroupId $team.GroupId -ErrorAction Stop | Sort-Object DisplayName | ForEach-Object {
                if ((-not $PSBoundParameters.ContainsKey('Channel')) -or ($_.DisplayName -like "*$($Channel)*")) {
                    $result += [PSCustomObject]@{
                        Team            = $team.DisplayName
                        Channel         = $_.DisplayName
                        Description     = $_.Description
                        ChannelType     = $_.MembershipType
                    }
                }
            }
        }

        if ($result.Count -eq 0) {
            Write-Output "No channels found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
