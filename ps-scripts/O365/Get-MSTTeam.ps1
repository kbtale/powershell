#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get teams with properties
.DESCRIPTION
    Retrieves Microsoft Teams with particular properties. Supports filtering by GroupId, DisplayName, MailNickName, Visibility, and archived state.
.PARAMETER GroupId
    GroupId of the team
.PARAMETER Archived
    Filters to return teams that have been archived or not
.PARAMETER DisplayName
    Filters to return teams with a full match to the provided display name
.PARAMETER MailNickName
    Specify the mail nickname of the team to return
.PARAMETER Visibility
    Filters to return teams with a specific visibility value
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-MSTTeam.ps1
.EXAMPLE
    PS> ./Get-MSTTeam.ps1 -DisplayName "Engineering" -Visibility "Private"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$GroupId,
    [bool]$Archived,
    [string]$DisplayName,
    [string]$MailNickName,
    [ValidateSet('Public', 'Private')]
    [string]$Visibility,
    [ValidateSet('*', 'GroupId', 'DisplayName', 'Description', 'Visibility', 'MailNickName', 'Archived')]
    [string[]]$Properties = @('GroupId', 'DisplayName', 'Description', 'Visibility', 'MailNickName', 'Archived')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'Archived' = $Archived}

        if (-not [System.String]::IsNullOrWhiteSpace($GroupId)) {
            $getArgs.Add('GroupId', $GroupId)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) {
            $getArgs.Add('DisplayName', $DisplayName)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($MailNickName)) {
            $getArgs.Add('MailNickName', $MailNickName)
        }
        if (-not [System.String]::IsNullOrWhiteSpace($Visibility)) {
            $getArgs.Add('Visibility', $Visibility)
        }

        $result = Get-Team @getArgs | Sort-Object DisplayName | Select-Object $Properties

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No teams found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
