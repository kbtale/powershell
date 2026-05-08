#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Get Teams App installations
.DESCRIPTION
    Retrieves Teams App installations scoped to a Team or User in Microsoft Teams. Supports optional filtering by AppId or InstallationId.
.PARAMETER TeamID
    Team identifier in Microsoft Teams
.PARAMETER UserID
    User identifier in Microsoft Teams
.PARAMETER AppId
    Teams App identifier in Microsoft Teams
.PARAMETER AppInstallationId
    Installation identifier of the Teams App
.EXAMPLE
    PS> ./Get-MSTTeamsAppInstallation.ps1 -TeamID "group-id"
.EXAMPLE
    PS> ./Get-MSTTeamsAppInstallation.ps1 -UserID "user-id" -AppId "app-guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'byTeam')]
    [string]$TeamID,
    [Parameter(Mandatory = $true, ParameterSetName = 'byUser')]
    [string]$UserID,
    [Parameter(ParameterSetName = 'byTeam')]
    [Parameter(ParameterSetName = 'byUser')]
    [string]$AppId,
    [Parameter(ParameterSetName = 'byTeam')]
    [Parameter(ParameterSetName = 'byUser')]
    [string]$AppInstallationId
)

Process {
    try {
        [string[]]$Properties = @('DisplayName', 'TeamsAppId', 'Version', 'TeamsAppDefinitionId')
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}

        if ($PSCmdlet.ParameterSetName -eq 'byTeam') {
            $cmdArgs.Add('TeamID', $TeamID)
        }
        else {
            $cmdArgs.Add('UserID', $UserID)
        }
        if ($PSBoundParameters.ContainsKey('AppId')) {
            $cmdArgs.Add('AppId', $AppId)
        }
        if ($PSBoundParameters.ContainsKey('AppInstallationId')) {
            $cmdArgs.Add('AppInstallationId', $AppInstallationId)
        }

        $result = Get-TeamsAppInstallation @cmdArgs | Sort-Object DisplayName | Select-Object $Properties

        if ($null -eq $result -or $result.Count -eq 0) {
            Write-Output "No app installations found"
            return
        }
        foreach ($item in $result) {
            $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
        }
    }
    catch { throw }
}
