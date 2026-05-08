#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes an environment role assignment
.DESCRIPTION
    Deletes a role assignment from an environment.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER EnvironmentName
    The environment name
.PARAMETER RoleId
    The role assignment ID to remove
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-EnvironmentRoleAssignment.ps1 -PACredential $cred -EnvironmentName "default" -RoleId "abc"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$EnvironmentName,
    [string]$RoleId,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('RoleId')) { $args.Add('RoleId', $RoleId) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppEnvironmentRoleAssignment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Environment role assignment removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
