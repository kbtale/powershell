#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get users of a channel
.DESCRIPTION
    Retrieves users assigned to a private channel in Microsoft Teams. Supports optional role filtering.
.PARAMETER GroupId
    GroupId of the parent team
.PARAMETER DisplayName
    Display name of the private channel
.PARAMETER Role
    Filter results to only users with the given role (Member, Owner, Guest)
.EXAMPLE
    PS> ./Get-MSTTeamChannelUser.ps1 -GroupId "group-id" -DisplayName "Private Channel"
.EXAMPLE
    PS> ./Get-MSTTeamChannelUser.ps1 -GroupId "group-id" -DisplayName "Private Channel" -Role "Owner"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [ValidateSet('Member', 'Owner', 'Guest')]
    [string]$Role
)

Process {
    try {
        [string[]]$Properties = @('Name', 'User', 'Role', 'UserID')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'; 'GroupId' = $GroupId; 'DisplayName' = $DisplayName}

        if (-not [System.String]::IsNullOrWhiteSpace($Role)) {
            $cmdArgs.Add('Role', $Role)
        }
        $result = Get-TeamChannelUser @cmdArgs | Sort-Object Name | Select-Object $Properties

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No channel users found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
