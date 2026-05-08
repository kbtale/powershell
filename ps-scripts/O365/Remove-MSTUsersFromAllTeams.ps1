#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Remove owners or members from all teams
.DESCRIPTION
    Removes specified users from all teams in Microsoft Teams.
.PARAMETER Users
    One or more User UPNs
.PARAMETER Role
    User role filter for removal (Member or Owner)
.EXAMPLE
    PS> ./Remove-MSTUsersFromAllTeams.ps1 -Users @("user1@domain.com","user2@domain.com")
.EXAMPLE
    PS> ./Remove-MSTUsersFromAllTeams.ps1 -Users @("admin@domain.com") -Role "Owner"
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
                    $null = Remove-TeamUser @cmdArgs -GroupId $team.GroupId -User ($usr.Trim())
                    $result += "User $($usr) removed from team $($team.DisplayName)"
                }
                catch {
                    $result += "Error removing user $($usr) from team $($team.DisplayName)"
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
