#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Sets app owner
.DESCRIPTION
    Changes the owner of a PowerApp.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER EnvironmentName
    The app's environment
.PARAMETER Owner
    New owner email or object ID
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-PowerAppOwner.ps1 -PACredential $cred -AppName "my-app" -EnvironmentName "default" -Owner "new.owner@contoso.com"
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

    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; AppName = $AppName; EnvironmentName = $EnvironmentName; AppOwner = $Owner }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $null = Set-AdminPowerAppOwner @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Owner set to '$Owner' for '$AppName'" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
