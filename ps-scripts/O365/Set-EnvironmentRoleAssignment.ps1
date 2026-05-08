#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets an environment role assignment
.DESCRIPTION
    Assigns a role to a principal on an environment.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER EnvironmentName
    The environment name
.PARAMETER PrincipalObjectId
    Object ID of the user/group
.PARAMETER RoleName
    Role: EnvironmentMaker, EnvironmentAdmin
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-EnvironmentRoleAssignment.ps1 -PACredential $cred -EnvironmentName "default" -PrincipalObjectId "guid" -RoleName EnvironmentAdmin
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [Parameter(Mandatory = $true)]
    [ValidateSet('EnvironmentMaker', 'EnvironmentAdmin')]
    [string]$RoleName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; EnvironmentName = $EnvironmentName; PrincipalObjectId = $PrincipalObjectId; RoleName = $RoleName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppEnvironmentRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
