#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Adds owners or members to a team
.DESCRIPTION
    Adds one or more users as owners or members to a team in Microsoft Teams.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER User
    User's UPN (user principal name) for single user addition
.PARAMETER Users
    One or more User UPN's for bulk addition
.PARAMETER Role
    User role (Member or Owner)
.EXAMPLE
    PS> ./Add-MSTTeamUser.ps1 -GroupId "group-id" -User "user@domain.com"
.EXAMPLE
    PS> ./Add-MSTTeamUser.ps1 -GroupId "group-id" -Users @("user1@domain.com","user2@domain.com") -Role "Owner"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Multi')]
    [string]$GroupId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [string]$User,
    [Parameter(Mandatory = $true, ParameterSetName = 'Multi')]
    [string[]]$Users,
    [Parameter(ParameterSetName = 'Single')]
    [Parameter(ParameterSetName = 'Multi')]
    [ValidateSet('Member', 'Owner')]
    [string]$Role
)

Process {
    try {
        $team = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

        if (-not [System.String]::IsNullOrWhiteSpace($Role)) {
            $cmdArgs.Add('Role', $Role)
        }

        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $Users = @($User)
        }

        $result = @()
        foreach ($usr in $Users) {
            try {
                $null = Add-TeamUser @cmdArgs -User $usr
                $result += "User $($usr) added to team $($team)"
            }
            catch {
                $result += "Error adding user $($usr) to team $($team)"
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
