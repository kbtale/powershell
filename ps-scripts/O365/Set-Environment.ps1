#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Updates an environment
.DESCRIPTION
    Modifies properties of a PowerApps environment.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER EnvironmentName
    The environment to update
.PARAMETER DisplayName
    New display name
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-Environment.ps1 -PACredential $cred -EnvironmentName "default" -DisplayName "My Environment"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [string]$DisplayName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; EnvironmentName = $EnvironmentName }
        if ($PSBoundParameters.ContainsKey('DisplayName')) { $args.Add('DisplayName', $DisplayName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminPowerAppEnvironment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
