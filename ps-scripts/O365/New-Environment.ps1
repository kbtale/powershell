#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Creates an environment
.DESCRIPTION
    Creates a new PowerApps environment.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER DisplayName
    Display name for the environment
.PARAMETER LocationName
    Geographic location for the environment
.PARAMETER EnvironmentSku
    SKU type: Production, Sandbox, Trial
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./New-Environment.ps1 -PACredential $cred -DisplayName "Dev Environment" -LocationName "unitedstates"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [string]$LocationName,

    [ValidateSet('Production', 'Sandbox', 'Trial')]
    [string]$EnvironmentSku = 'Production',

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; DisplayName = $DisplayName; LocationName = $LocationName; EnvironmentSku = $EnvironmentSku }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = New-AdminPowerAppEnvironment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
