#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get all channels for a team
.DESCRIPTION
    Retrieves all channels for a specified team in Microsoft Teams.
.PARAMETER GroupId
    GroupId of the team
.EXAMPLE
    PS> ./Get-MSTTeamChannel.ps1 -GroupId "group-id"
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

        $result = Get-TeamChannel @cmdArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No team channels found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
