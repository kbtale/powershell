#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a PowerApp
.DESCRIPTION
    Deletes a PowerApp.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-PowerApp.ps1 -PACredential $cred -AppName "my-app" -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; AppName = $AppName; EnvironmentName = $EnvironmentName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerApp @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "App '$AppName' removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
