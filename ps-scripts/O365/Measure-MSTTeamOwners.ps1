#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Check the number of owners per team
.DESCRIPTION
    Checks each team for the minimum number of owners and reports teams below the threshold.
.PARAMETER ThresholdValue
    Minimum number of owners required (1-10)
.PARAMETER Archived
    Filters to include or exclude archived teams
.EXAMPLE
    PS> ./Measure-MSTTeamOwners.ps1
.EXAMPLE
    PS> ./Measure-MSTTeamOwners.ps1 -ThresholdValue 2
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [ValidateRange(1, 10)]
    [int]$ThresholdValue = 1,
    [bool]$Archived
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'Archived' = $Archived}

        $teams = Get-Team @getArgs
        $result = @()
        foreach ($item in $teams) {
            try {
                $users = Get-TeamUser -GroupId $item.GroupId -ErrorAction Stop | Where-Object { $_.Role -like 'owner' }
                if (($null -eq $users) -or ($users.Count -lt $ThresholdValue)) {
                    $ownerCount = if ($null -eq $users) { 0 } else { $users.Count }
                    [PSCustomObject]@{
                        Timestamp   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                        Team        = $item.DisplayName
                        GroupId     = $item.GroupId
                        OwnerCount  = $ownerCount
                        BelowThreshold = ($ownerCount -lt $ThresholdValue)
                    }
                }
            }
            catch {
                Write-Output "Error reading team users from team $($item.DisplayName)"
            }
        }
        if ($result.Count -eq 0) {
            Write-Output "All teams meet the minimum owner threshold"
        }
        else {
            Write-Output $result
        }
    }
    catch { throw }
}
