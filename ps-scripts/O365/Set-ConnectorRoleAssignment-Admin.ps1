#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets a connector role assignment
.DESCRIPTION
    Assigns a permission role to a principal on a connector.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER PrincipalObjectId
    Object ID of the user/group
.PARAMETER RoleName
    Permission: CanView, CanEdit
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-ConnectorRoleAssignment-Admin.ps1 -PACredential $cred -ConnectorName "my-conn" -PrincipalObjectId "guid" -RoleName CanEdit
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ConnectorName,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CanView', 'CanEdit')]
    [string]$RoleName,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectorName = $ConnectorName; PrincipalObjectId = $PrincipalObjectId; RoleName = $RoleName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppConnectorRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
