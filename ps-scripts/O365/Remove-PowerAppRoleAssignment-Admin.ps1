#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes an app role assignment
.DESCRIPTION
    Deletes a specific role assignment from an app.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER RoleId
    The role assignment ID to remove
.PARAMETER AppName
    The app identifier
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-PowerAppRoleAssignment-Admin.ps1 -PACredential $cred -RoleId "abc" -AppName "my-app" -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$RoleId,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $cmdArgs = @{ ErrorAction = 'Stop'; AppName = $AppName; EnvironmentName = $EnvironmentName; RoleId = $RoleId }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $cmdArgs.Add('ApiVersion', $ApiVersion) }
        $result = Remove-AdminPowerAppRoleAssignment @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
