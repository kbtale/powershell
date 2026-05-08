#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves connector role assignments
.DESCRIPTION
    Returns role assignments for connectors, filterable by connector name, environment, or principal.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER PrincipalObjectId
    Filter by user/group object ID
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve
.EXAMPLE
    PS> ./Get-ConnectorRoleAssignment-Admin.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ConnectorName,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [string]$ApiVersion,

    [ValidateSet('*', 'PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'ConnectorName', 'EnvironmentName', 'PrincipalObjectId', 'PrincipalType', 'RoleType', 'Internal')]
    [string[]]$Properties = @('PrincipalDisplayName', 'RoleName', 'RoleId', 'PrincipalEmail', 'ConnectorName', 'EnvironmentName')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        ConnectPowerApps -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ConnectorName')) { $getArgs.Add('ConnectorName', $ConnectorName) }
        if ($PSBoundParameters.ContainsKey('PrincipalObjectId')) { $getArgs.Add('PrincipalObjectId', $PrincipalObjectId) }
        $result = Get-AdminPowerAppConnectorRoleAssignment @getArgs -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
