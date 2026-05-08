#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Removes a connection
.DESCRIPTION
    Deletes a connection from the tenant.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER ConnectionName
    The connection identifier to remove
.PARAMETER ConnectorName
    The connection's connector name
.PARAMETER EnvironmentName
    The connection's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-Connection-Admin.ps1 -PACredential $cred -ConnectionName "my-conn" -ConnectorName "shared_sql" -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$ConnectionName,

    [Parameter(Mandatory = $true)]
    [string]$ConnectorName,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; ConnectorName = $ConnectorName; ConnectionName = $ConnectionName; EnvironmentName = $EnvironmentName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Remove-AdminPowerAppConnection @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
