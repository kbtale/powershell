#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves PowerApp role assignments
.DESCRIPTION
    Returns app role assignments for a user or an app.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER PrincipalObjectId
    Object ID of a user or group to filter by
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-PowerAppRoleAssignment.ps1 -PACredential $cred -AppName "my-app"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$AppName,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [string]$ApiVersion,

    [ValidateSet('*', 'PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'AppName', 'EnvironmentName', 'PrincipalObjectId', 'PrincipalType', 'RoleType', 'Internal')]
    [string[]]$Properties = @('PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'AppName', 'EnvironmentName')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('AppName')) { $getArgs.Add('AppName', $AppName) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('PrincipalObjectId')) { $getArgs.Add('PrincipalObjectId', $PrincipalObjectId) }

        $result = Get-PowerAppRoleAssignment @getArgs -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
