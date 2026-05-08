#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a connector
.DESCRIPTION
    Deletes a custom connector.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-Connector.ps1 -PACredential $cred -ConnectorName "my-connector" -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ConnectorName,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectorName = $ConnectorName; EnvironmentName = $EnvironmentName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppConnector @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Connector '$ConnectorName' removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
