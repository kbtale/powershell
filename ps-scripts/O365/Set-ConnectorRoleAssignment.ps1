#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Sets a connector role assignment
.DESCRIPTION
    Assigns a role to a user/group for a connector.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER PrincipalObjectId
    Principal object ID to assign
.PARAMETER RoleName
    Role to assign: CanView, CanEdit
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-ConnectorRoleAssignment.ps1 -PACredential $cred -PrincipalObjectId "guid" -RoleName CanEdit
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('CanView', 'CanEdit')]
    [string]$RoleName,

    [string]$ConnectorName,
    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; PrincipalObjectId = $PrincipalObjectId; RoleName = $RoleName }
        if ($PSBoundParameters.ContainsKey('ConnectorName')) { $args.Add('ConnectorName', $ConnectorName) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppConnectorRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
