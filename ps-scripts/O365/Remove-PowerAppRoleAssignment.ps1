#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a PowerApp role assignment
.DESCRIPTION
    Deletes a role assignment from a PowerApp.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER PrincipalObjectId
    The assignee to remove
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-PowerAppRoleAssignment.ps1 -PACredential $cred -AppName "my-app"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; AppName = $AppName; PrincipalObjectId = $PrincipalObjectId }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppRoleAssignment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "App role assignment removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
