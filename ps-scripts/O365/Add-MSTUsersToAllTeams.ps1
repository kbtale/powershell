#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Adds owners or members to all teams
.DESCRIPTION
    Adds specified users as owners or members to all teams in Microsoft Teams.
.PARAMETER Users
    One or more User UPNs
.PARAMETER Role
    User role (Member or Owner)
.EXAMPLE
    PS> ./Add-MSTUsersToAllTeams.ps1 -Users @("user1@domain.com","user2@domain.com")
.EXAMPLE
    PS> ./Add-MSTUsersToAllTeams.ps1 -Users @("admin@domain.com") -Role "Owner"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string[]]$Users,
    [ValidateSet('Member', 'Owner')]
    [string]$Role
)

Process {
    try {
        $teams = Get-Team -ErrorAction Stop
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
        if ($PSBoundParameters.ContainsKey('Role')) {
            $cmdArgs.Add('Role', $Role)
        }

        [string[]]$result = @()
        foreach ($team in $teams) {
            foreach ($usr in $Users) {
                try {
                    $null = Add-TeamUser @cmdArgs -GroupId $team.GroupId -User ($usr.Trim())
                    $result += "User $($usr) added to team $($team.DisplayName)"
                }
                catch {
                    $result += "Error adding user $($usr) to team $($team.DisplayName)"
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
