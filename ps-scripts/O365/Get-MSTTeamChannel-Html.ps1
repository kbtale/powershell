#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of channels for a team
.DESCRIPTION
    Generates an HTML report with the channels of a specific team.
.PARAMETER GroupId
    GroupId of the team
.EXAMPLE
    PS> ./Get-MSTTeamChannel-Html.ps1 -GroupId "group-id" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

        $result = Get-TeamChannel @cmdArgs | Select-Object DisplayName, Description, Id

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No channels found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
