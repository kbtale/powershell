#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves app role assignments
.DESCRIPTION
    Returns permission information for apps, filterable by app, user, or environment.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER UserId
    Filter by user object ID
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-PowerAppRoleAssignment-Admin.ps1 -PACredential $cred -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Environment")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "App")]
    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [Parameter(Mandatory = $true, ParameterSetName = "Environment")]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true, ParameterSetName = "App")]
    [string]$AppName,

    [Parameter(ParameterSetName = "App")]
    [Parameter(ParameterSetName = "User")]
    [Parameter(ParameterSetName = "Environment")]
    [string]$ApiVersion,

    [Parameter(Mandatory = $true, ParameterSetName = "App")]
    [Parameter(Mandatory = $true, ParameterSetName = "Environment")]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true, ParameterSetName = "Environment")]
    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [Parameter(ParameterSetName = "App")]
    [string]$UserId,

    [ValidateSet('*', 'PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'AppName', 'EnvironmentName', 'PrincipalObjectId', 'PrincipalType', 'RoleType', 'Internal')]
    [string[]]$Properties = @('PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'AppName', 'EnvironmentName')
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSCmdlet.ParameterSetName -eq "App") { $getArgs.Add('AppName', $AppName); $getArgs.Add('EnvironmentName', $EnvironmentName) }
        elseif ($PSCmdlet.ParameterSetName -eq "User") { $getArgs.Add('UserId', $UserId) }
        elseif ($PSCmdlet.ParameterSetName -eq "Environment") { $getArgs.Add('UserId', $UserId); $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        $result = Get-AdminPowerAppRoleAssignment @getArgs -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
