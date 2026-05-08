#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets the current environment
.DESCRIPTION
    Switches the active PowerApps environment context for subsequent admin operations.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER EnvironmentName
    The environment to switch to
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Select-CurrentEnvironment-Admin.ps1 -PACredential $cred -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; EnvironmentName = $EnvironmentName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $null = Set-AdminCurrentEnvironment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Current environment set to '$EnvironmentName'" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
