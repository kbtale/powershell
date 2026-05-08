#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Set the archived state of a team
.DESCRIPTION
    Sets the archived state of a team in Microsoft Teams. Supports optionally making the SharePoint site read-only for members.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER Archived
    Archived state (true to archive, false to unarchive)
.PARAMETER SetSpoSiteReadOnlyForMembers
    Sets the SharePoint site to read-only for team members
.EXAMPLE
    PS> ./Set-MSTTeamArchivedState.ps1 -GroupId "group-id" -Archived $true
.EXAMPLE
    PS> ./Set-MSTTeamArchivedState.ps1 -GroupId "group-id" -Archived $true -SetSpoSiteReadOnlyForMembers $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [bool]$Archived,
    [bool]$SetSpoSiteReadOnlyForMembers
)

Process {
    try {
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'Archived' = $Archived}

        if ($PSBoundParameters.ContainsKey('SetSpoSiteReadOnlyForMembers')) {
            $cmdArgs.Add('SetSpoSiteReadOnlyForMembers', $SetSpoSiteReadOnlyForMembers)
        }

        $result = Set-TeamArchivedState @cmdArgs | Select-Object *

        if ($null -eq $result) {
            $state = if ($Archived) { 'archived' } else { 'unarchived' }
            Write-Output "Team $GroupId $state successfully"
            return
        }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
