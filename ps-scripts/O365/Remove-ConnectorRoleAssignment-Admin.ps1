#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes a connector role assignment
.DESCRIPTION
    Deletes a role assignment from a connector.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER ConnectorName
    The connector identifier
.PARAMETER PrincipalObjectId
    The assignee to remove
.PARAMETER EnvironmentName
    The connector's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-ConnectorRoleAssignment-Admin.ps1 -PACredential $cred -ConnectorName "my-conn" -PrincipalObjectId "guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ConnectorName,
    [string]$PrincipalObjectId,
    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ConnectorName')) { $args.Add('ConnectorName', $ConnectorName) }
        if ($PSBoundParameters.ContainsKey('PrincipalObjectId')) { $args.Add('PrincipalObjectId', $PrincipalObjectId) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-AdminPowerAppConnectorRoleAssignment @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Connector role assignment removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
