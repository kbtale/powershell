#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Remove owners or members from a team
.DESCRIPTION
    Removes one or more users from a team in Microsoft Teams. The last owner cannot be removed.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER Users
    One or more User UPNs for bulk removal
.PARAMETER User
    User's UPN for single user removal
.PARAMETER UserIsOwner
    Indicates the user is in the owner role
.EXAMPLE
    PS> ./Remove-MSTTeamUser.ps1 -GroupId "group-id" -User "user@domain.com"
.EXAMPLE
    PS> ./Remove-MSTTeamUser.ps1 -GroupId "group-id" -Users @("user1@domain.com","user2@domain.com")
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Multi')]
    [string]$GroupId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Multi')]
    [string[]]$Users,
    [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
    [string]$User,
    [Parameter(ParameterSetName = 'Single')]
    [switch]$UserIsOwner
)

Process {
    try {
        $team = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object -ExpandProperty DisplayName
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            $Users = @($User)
        }
        else {
            if ($UserIsOwner) {
                $cmdArgs.Add('Role', 'Owner')
            }
        }

        $result = @()
        foreach ($usr in $Users) {
            try {
                $null = Remove-TeamUser @cmdArgs -User $usr
                $result += "User $($usr) removed from team $($team)"
            }
            catch {
                $result += "Error removing user $($usr) from team $($team)"
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
