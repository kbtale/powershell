#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Delete a channel from a team
.DESCRIPTION
    Removes a specified channel from a Microsoft Team.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER DisplayName
    Channel display name to remove
.EXAMPLE
    PS> ./Remove-MSTTeamChannel.ps1 -GroupId "group-id" -DisplayName "Old Channel"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [ValidateLength(5, 50)]
    [string]$DisplayName
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'DisplayName' = $DisplayName; 'GroupId' = $GroupId}

        $null = Remove-TeamChannel @cmdArgs

        [PSCustomObject]@{
            Timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            GroupId     = $GroupId
            DisplayName = $DisplayName
            Status      = "Team channel '$DisplayName' successfully removed"
        }
    }
    catch { throw }
}
