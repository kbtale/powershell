#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get users of a team
.DESCRIPTION
    Returns users of a team in Microsoft Teams. Supports optional filtering by role.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER Role
    Filter results to only users with the given role (Member, Owner, Guest)
.EXAMPLE
    PS> ./Get-MSTTeamUser.ps1 -GroupId "group-id"
.EXAMPLE
    PS> ./Get-MSTTeamUser.ps1 -GroupId "group-id" -Role "Owner"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [ValidateSet('Member', 'Owner', 'Guest')]
    [string]$Role
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId}

        if (-not [System.String]::IsNullOrWhiteSpace($Role)) {
            $cmdArgs.Add('Role', $Role)
        }

        $result = Get-TeamUser @cmdArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No team users found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
