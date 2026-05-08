#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes a connection role assignment
.DESCRIPTION
    Deletes a role assignment from a connection.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER ConnectionName
    The connection identifier
.PARAMETER ConnectorName
    The connection's connector name
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER RoleId
    The role assignment ID to remove
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-ConnectionRoleAssignment-Admin.ps1 -PACredential $cred -ConnectionName "my-conn" -RoleId "abc"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ConnectionName,
    [string]$ConnectorName,
    [string]$EnvironmentName,
    [string]$RoleId,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ConnectorName')) { $args.Add('ConnectorName', $ConnectorName) }
        if ($PSBoundParameters.ContainsKey('ConnectionName')) { $args.Add('ConnectionName', $ConnectionName) }
        if ($PSBoundParameters.ContainsKey('RoleId')) { $args.Add('RoleId', $RoleId) }
        $result = Remove-AdminPowerAppConnectionRoleAssignment @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
