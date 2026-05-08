#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets a connection role assignment
.DESCRIPTION
    Assigns a permission role to a principal on a connection.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER ConnectorName
    The connection's connector name
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER PrincipalObjectId
    Object ID of the user/group/tenant
.PARAMETER RoleName
    Permission: CanView, CanViewWithShare, CanEdit
.PARAMETER PrincipalType
    Type: User, Group, Tenant
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-ConnectionRoleAssignment-Admin.ps1 -PACredential $cred -ConnectionName "my-conn" -ConnectorName "sql" -EnvironmentName "default" -PrincipalObjectId "guid" -RoleName CanEdit -PrincipalType User
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ConnectionName,

    [Parameter(Mandatory = $true)]
    [string]$ConnectorName,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CanView', 'CanViewWithShare', 'CanEdit')]
    [string]$RoleName,

    [Parameter(Mandatory = $true)]
    [ValidateSet('User', 'Group', 'Tenant')]
    [string]$PrincipalType,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectionName = $ConnectionName; ConnectorName = $ConnectorName; EnvironmentName = $EnvironmentName; RoleName = $RoleName; PrincipalType = $PrincipalType; PrincipalObjectId = $PrincipalObjectId }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppConnectionRoleAssignment @args -ErrorAction Stop | Select-Object PrincipalDisplayName, RoleName, RoleId, PrincipalEmail, ConnectionName, ConnectorName, EnvironmentName
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
