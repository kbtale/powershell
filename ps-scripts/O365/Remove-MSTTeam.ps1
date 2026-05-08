#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Deletes a Team from Microsoft Teams
.DESCRIPTION
    Removes a specified team via GroupId and all its associated components including the O365 Unified Group.
.PARAMETER GroupId
    GroupId of the team
.EXAMPLE
    PS> ./Remove-MSTTeam.ps1 -GroupId "group-id"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId
)

Process {
    try {
        $teamInfo = Get-Team -GroupId $GroupId -ErrorAction Stop | Select-Object DisplayName
        $null = Remove-Team -GroupId $GroupId -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            GroupId     = $GroupId
            DisplayName = $teamInfo.DisplayName
            Status      = "Team '$($teamInfo.DisplayName)' successfully removed"
        }
    }
    catch { throw }
}
