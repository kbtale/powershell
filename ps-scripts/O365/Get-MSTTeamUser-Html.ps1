#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of users of a team
.DESCRIPTION
    Generates an HTML report with the users and their roles for a specific team.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER Role
    Filter results to only users with the given role
.EXAMPLE
    PS> ./Get-MSTTeamUser-Html.ps1 -GroupId "group-id" | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTTeamUser-Html.ps1 -GroupId "group-id" -Role "Owner" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [ValidateSet('Member','Owner','Guest')]
    [string]$Role
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}
        if (-not [System.String]::IsNullOrWhiteSpace($Role)) {
            $cmdArgs.Add('Role', $Role)
        }

        $result = Get-TeamUser @cmdArgs | Select-Object Name, User, Role, UserID

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No team users found"
            return
        }

        Write-Output ($result | Sort-Object Name | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
