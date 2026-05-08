#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets app role assignment
.DESCRIPTION
    Assigns a role to a user/group for an app.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER PrincipalObjectId
    Principal object ID to assign
.PARAMETER RoleName
    Role: CanView, CanEdit, CanViewWithShare
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-PowerAppRoleAssignment-Admin.ps1 -PACredential $cred -AppName "my-app" -PrincipalObjectId "guid" -RoleName CanEdit
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CanView', 'CanEdit', 'CanViewWithShare')]
    [string]$RoleName,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; AppName = $AppName; PrincipalObjectId = $PrincipalObjectId; RoleName = $RoleName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
