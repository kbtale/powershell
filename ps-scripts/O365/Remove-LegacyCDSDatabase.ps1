#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a legacy CDS database
.DESCRIPTION
    Deletes a legacy Common Data Service database.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER EnvironmentName
    The environment containing the database
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-LegacyCDSDatabase.ps1 -PACredential $cred -EnvironmentName "default"
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
        Remove-AdminPowerAppLegacyCDSDatabase @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Legacy CDS database removed from '$EnvironmentName'" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
