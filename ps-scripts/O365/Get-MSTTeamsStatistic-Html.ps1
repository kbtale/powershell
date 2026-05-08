#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of team statistics
.DESCRIPTION
    Generates an HTML report with team information and statistics. Supports extended reports with user roles.
.PARAMETER GroupId
    Specify the GroupId of a specific team
.PARAMETER ExtendedReport
    Extended output with team users and their roles
.PARAMETER Archived
    Filters to return teams that have been archived or not
.PARAMETER Visibility
    Filters to return teams with a specific visibility
.EXAMPLE
    PS> ./Get-MSTTeamsStatistic-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTTeamsStatistic-Html.ps1 -ExtendedReport | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$GroupId,
    [switch]$ExtendedReport,
    [bool]$Archived,
    [ValidateSet('Public','Private')]
    [string]$Visibility
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}
        if (-not [System.String]::IsNullOrWhiteSpace($GroupId)) { $getArgs.Add('GroupId', $GroupId) }
        if ($PSBoundParameters.ContainsKey('Archived')) { $getArgs.Add('Archived', $Archived) }
        if (-not [System.String]::IsNullOrWhiteSpace($Visibility)) { $getArgs.Add('Visibility', $Visibility) }

        $teams = Get-Team @getArgs | Sort-Object DisplayName
        $result = @()

        foreach ($team in $teams) {
            $channels = Get-TeamChannel -GroupId $team.GroupId -ErrorAction Stop
            $owners = Get-TeamUser -GroupId $team.GroupId -Role Owner -ErrorAction Stop
            $members = Get-TeamUser -GroupId $team.GroupId -Role Member -ErrorAction Stop
            $guests = Get-TeamUser -GroupId $team.GroupId -Role Guest -ErrorAction Stop

            $obj = [PSCustomObject]@{
                Team           = $team.DisplayName
                GroupId        = $team.GroupId
                Visibility     = $team.Visibility
                Archived       = $team.Archived
                ChannelCount   = $channels.Count
                OwnerCount     = $owners.Count
                MemberCount    = $members.Count
                GuestCount     = $guests.Count
            }

            if ($ExtendedReport) {
                $obj | Add-Member -NotePropertyName Owners -NotePropertyValue ($owners.Name -join ', ')
                $obj | Add-Member -NotePropertyName Members -NotePropertyValue ($members.Name -join ', ')
                $obj | Add-Member -NotePropertyName Guests -NotePropertyValue ($guests.Name -join ', ')
            }

            $result += $obj
        }

        if ($result.Count -eq 0) {
            Write-Output "No teams found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
