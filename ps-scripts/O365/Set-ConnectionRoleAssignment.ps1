#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Sets a connection role assignment
.DESCRIPTION
    Assigns a role to a user/group for a connection.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER PrincipalObjectId
    Principal object ID to assign
.PARAMETER RoleName
    Role to assign: CanView, CanEdit, CanViewWithShare
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-ConnectionRoleAssignment.ps1 -PACredential $cred -ConnectionName "my-conn" -PrincipalObjectId "guid" -RoleName CanEdit
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ConnectionName,

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
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectionName = $ConnectionName; PrincipalObjectId = $PrincipalObjectId; RoleName = $RoleName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppConnectionRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
