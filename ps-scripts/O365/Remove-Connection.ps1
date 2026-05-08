#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a connection
.DESCRIPTION
    Deletes a PowerApps connection.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-Connection.ps1 -PACredential $cred -ConnectionName "my-connection"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ConnectionName,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectionName = $ConnectionName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppConnection @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Connection '$ConnectionName' removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
