#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves connection role assignments
.DESCRIPTION
    Returns role assignments for a connection or all role assignments for a user across connections.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER PrincipalObjectId
    Object ID of a user or group to filter by
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-ConnectionRoleAssignment.ps1 -PACredential $cred -ConnectionName "my-connection"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ConnectionName,
    [string]$ConnectorName,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [string]$ApiVersion,

    [ValidateSet('*', 'PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'ConnectionName', 'ConnectorName', 'EnvironmentName', 'PrincipalObjectId', 'PrincipalType', 'RoleType', 'Internal')]
    [string[]]$Properties = @('PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'ConnectionName', 'ConnectorName', 'EnvironmentName')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ConnectorName')) { $getArgs.Add('ConnectorName', $ConnectorName) }
        if ($PSBoundParameters.ContainsKey('ConnectionName')) { $getArgs.Add('ConnectionName', $ConnectionName) }
        if ($PSBoundParameters.ContainsKey('PrincipalObjectId')) { $getArgs.Add('PrincipalObjectId', $PrincipalObjectId) }

        $result = Get-PowerAppConnectionRoleAssignment @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
