#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Query-format list of teams
.DESCRIPTION
    Returns Microsoft Teams as Value/DisplayValue pairs for use in dropdown selectors.
.EXAMPLE
    PS> ./QRY_Get-MSTTeam.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param()

Process {
    try {
        $teams = Get-Team -ErrorAction Stop | Sort-Object -Property DisplayName

        if ($null -eq $teams -or $teams.Count -eq 0) {
            Write-Output "No teams found"
            return
        }
        foreach ($itm in $teams) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
                Value        = $itm.GroupId
                DisplayValue = $itm.DisplayName
            }
        }
    }
    catch { throw }
}
