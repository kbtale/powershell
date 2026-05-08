#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves connection role assignments
.DESCRIPTION
    Returns role assignments for connections in the tenant.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER PrincipalObjectId
    Filter by user/group object ID
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-ConnectionRoleAssignment-Admin.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ConnectionName,
    [string]$PrincipalObjectId,
    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ConnectionName')) { $args.Add('ConnectionName', $ConnectionName) }
        if ($PSBoundParameters.ContainsKey('PrincipalObjectId')) { $args.Add('PrincipalObjectId', $PrincipalObjectId) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Get-AdminPowerAppConnectionRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
