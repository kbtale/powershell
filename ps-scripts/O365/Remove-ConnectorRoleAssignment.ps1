#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a connector role assignment
.DESCRIPTION
    Deletes a role assignment from a connector.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER PrincipalObjectId
    The assignee to remove
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-ConnectorRoleAssignment.ps1 -PACredential $cred -PrincipalObjectId "guid" -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [string]$EnvironmentName,
    [string]$ConnectorName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; PrincipalObjectId = $PrincipalObjectId }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ConnectorName')) { $args.Add('ConnectorName', $ConnectorName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppConnectorRoleAssignment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Connector role assignment removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
