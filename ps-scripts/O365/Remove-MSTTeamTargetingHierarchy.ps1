#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Remove team targeting hierarchy
.DESCRIPTION
    Removes the team targeting hierarchy configuration from the tenant.
.EXAMPLE
    PS> ./Remove-MSTTeamTargetingHierarchy.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}

        $result = Remove-TeamTargetingHierarchy @getArgs

        [PSCustomObject]@{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Status    = if ($null -eq $result) { 'Team targeting hierarchy removed' } else { $result.ToString() }
        }
    }
    catch { throw }
}
