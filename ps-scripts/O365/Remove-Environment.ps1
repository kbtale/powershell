#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes an environment
.DESCRIPTION
    Deletes a PowerApps environment.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER EnvironmentName
    The environment to remove
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-Environment.ps1 -PACredential $cred -EnvironmentName "my-env"
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
        Remove-AdminPowerAppEnvironment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Environment '$EnvironmentName' removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
