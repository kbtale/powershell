#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of team members by role
.DESCRIPTION
    Generates an HTML report with team members grouped by their roles across all teams.
.PARAMETER Roles
    One or more role types to include (Owner, Member, Guest)
.EXAMPLE
    PS> ./Get-MSTTeamMemberByRole-Html.ps1 -Roles "Owner","Member" | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTTeamMemberByRole-Html.ps1 -Roles "Guest" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Owner','Member','Guest')]
    [string[]]$Roles
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}
        $teams = Get-Team @getArgs | Sort-Object DisplayName
        $result = @()

        foreach ($team in $teams) {
            foreach ($grp in $Roles) {
                Get-TeamUser -GroupId $team.GroupId -Role $grp -ErrorAction Stop | Sort-Object Name | ForEach-Object {
                    $result += [PSCustomObject]@{
                        Team     = $team.DisplayName
                        UserName = $_.Name
                        User     = $_.User
                        Role     = $_.Role
                    }
                }
            }
        }

        if ($result.Count -eq 0) {
            Write-Output "No team members found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
