#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes connector from business data group
.DESCRIPTION
    Disassociates a connector from a DLP policy business data group.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER PolicyName
    The DLP policy name
.PARAMETER ConnectorName
    The connector to remove
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-ConnectorFromBusinessDataGroup.ps1 -PACredential $cred -PolicyName "MyPolicy" -ConnectorName "shared_sql"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$PolicyName,

    [Parameter(Mandatory = $true)]
    [string]$ConnectorName,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; PolicyName = $PolicyName; ConnectorName = $ConnectorName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-ConnectorFromBusinessDataGroup @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Connector '$ConnectorName' removed from business data group" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
