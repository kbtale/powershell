#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes an app
.DESCRIPTION
    Deletes an app from PowerApps.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-PowerApp-Admin.ps1 -PACredential $cred -AppName "my-app" -EnvironmentName "default"
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
        ConnectPowerApps -PAFCredential $PACredential
        $cmdArgs = @{ ErrorAction = 'Stop'; AppName = $AppName; EnvironmentName = $EnvironmentName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $cmdArgs.Add('ApiVersion', $ApiVersion) }
        $result = Remove-AdminPowerApp @cmdArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
