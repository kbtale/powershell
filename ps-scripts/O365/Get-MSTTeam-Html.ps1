#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: HTML report of teams
.DESCRIPTION
    Generates an HTML report with team information. Supports optional filtering by GroupId, Archived state, DisplayName, MailNickName, and Visibility.
.PARAMETER GroupId
    Specify the GroupId of a specific team
.PARAMETER Archived
    Filters to return teams that have been archived or not
.PARAMETER DisplayName
    Filters to return teams with a full match to the provided display name
.PARAMETER MailNickName
    Specify the mail nickname of the team
.PARAMETER Visibility
    Filters to return teams with a specific visibility value
.PARAMETER Properties
    List of properties to expand. Use * for all properties
.EXAMPLE
    PS> ./Get-MSTTeam-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MSTTeam-Html.ps1 -Visibility "Private" | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$GroupId,
    [bool]$Archived,
    [string]$DisplayName,
    [string]$MailNickName,
    [ValidateSet('Public','Private')]
    [string]$Visibility,
    [ValidateSet('*','GroupId','DisplayName','Description','Visibility','MailNickName','Archived')]
    [string[]]$Properties = @('GroupId','DisplayName','Description','Visibility','MailNickName','Archived')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'Archived' = $Archived}

        if (-not [System.String]::IsNullOrWhiteSpace($GroupId)) { $getArgs.Add('GroupId', $GroupId) }
        if (-not [System.String]::IsNullOrWhiteSpace($DisplayName)) { $getArgs.Add('DisplayName', $DisplayName) }
        if (-not [System.String]::IsNullOrWhiteSpace($MailNickName)) { $getArgs.Add('MailNickName', $MailNickName) }
        if (-not [System.String]::IsNullOrWhiteSpace($Visibility)) { $getArgs.Add('Visibility', $Visibility) }

        $result = Get-Team @getArgs | Sort-Object DisplayName | Select-Object $Properties

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No teams found"
            return
        }

        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
