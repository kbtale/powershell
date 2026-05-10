#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves connections for the calling user
.DESCRIPTION
    Returns PowerApps connections with optional filtering by name, environment, connector, or flow connections.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectionName
    A connection identifier
.PARAMETER ReturnFlowConnections
    Include connections created by flows
.PARAMETER EnvironmentName
    Limit to a specific environment
.PARAMETER ConnectorNameFilter
    Filter by connector name (wildcards supported)
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-Connection.ps1 -PACredential $cred -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ConnectionName,
    [switch]$ReturnFlowConnections,
    [string]$EnvironmentName,
    [string]$ConnectorNameFilter,
    [string]$ApiVersion,

    [ValidateSet('*', 'DisplayName', 'ConnectionName', 'ConnectorName', 'EnvironmentName', 'CreatedTime', 'CreatedBy', 'LastModifiedTime', 'FullConnectorName', 'ConnectionId', 'Statuses', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'ConnectionName', 'ConnectorName', 'EnvironmentName', 'LastModifiedTime', 'ConnectionId')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSBoundParameters.ContainsKey('ConnectorNameFilter')) { $getArgs.Add('ConnectorNameFilter', $ConnectorNameFilter) }
        if ($PSBoundParameters.ContainsKey('ConnectionName')) { $getArgs.Add('ConnectionName', $ConnectionName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ReturnFlowConnections')) { $getArgs.Add('ReturnFlowConnections', $ReturnFlowConnections) }

        $result = Get-PowerAppConnection @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
