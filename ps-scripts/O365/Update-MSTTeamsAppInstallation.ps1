#Requires -Version 5.1

<#
.SYNOPSIS
    Teams: Updates a Teams App installation
.DESCRIPTION
    Updates a Teams App installation scoped to a Team or User in Microsoft Teams. Supports optional parameters for AppId, InstallationId, and Permissions.
.PARAMETER TeamID
    Team identifier in Microsoft Teams
.PARAMETER UserID
    User identifier in Microsoft Teams
.PARAMETER AppId
    Teams App identifier in Microsoft Teams
.PARAMETER AppInstallationId
    Installation identifier of the Teams App
.PARAMETER Permissions
    RSC permissions for the Teams App, e.g. "TeamSettings.Read.Group ChannelMessage.Read.Group"
.EXAMPLE
    PS> ./Update-MSTTeamsAppInstallation.ps1 -TeamID "group-id" -AppId "app-guid"
.EXAMPLE
    PS> ./Update-MSTTeamsAppInstallation.ps1 -UserID "user-id" -AppId "app-guid" -Permissions "TeamSettings.Read.Group"
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
    [string]$AppInstallationId,
    [Parameter(ParameterSetName = 'byTeam')]
    [Parameter(ParameterSetName = 'byUser')]
    [string]$Permissions
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
        if ($PSBoundParameters.ContainsKey('Permissions')) {
            $cmdArgs.Add('Permissions', $Permissions)
        }

        $null = Update-TeamsAppInstallation @cmdArgs
        $cmdArgs.Remove('AppId')
        $cmdArgs.Remove('AppInstallationId')
        $cmdArgs.Remove('Permissions')
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
