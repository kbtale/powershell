#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a connection role assignment
.DESCRIPTION
    Deletes a role assignment from a connection.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER PrincipalObjectId
    The assignee to remove
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-ConnectionRoleAssignment.ps1 -PACredential $cred -ConnectionName "my-conn" -PrincipalObjectId "guid"
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

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectionName = $ConnectionName; PrincipalObjectId = $PrincipalObjectId }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppConnectionRoleAssignment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Role assignment removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
