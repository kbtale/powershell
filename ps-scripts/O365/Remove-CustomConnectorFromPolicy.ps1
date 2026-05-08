#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes custom connector from DLP policy
.DESCRIPTION
    Excludes a custom connector from a DLP policy.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER PolicyName
    The DLP policy name
.PARAMETER ConnectorName
    The custom connector to remove
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-CustomConnectorFromPolicy.ps1 -PACredential $cred -PolicyName "MyPolicy" -ConnectorName "my-conn"
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

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; PolicyName = $PolicyName; ConnectorName = $ConnectorName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-CustomConnectorFromPolicy @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Custom connector '$ConnectorName' removed from policy" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
