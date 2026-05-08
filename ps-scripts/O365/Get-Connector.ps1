#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves connectors
.DESCRIPTION
    Returns PowerApps connectors with optional filtering by name, environment, or custom connectors only.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ConnectorName
    Retrieve a specific connector by name
.PARAMETER EnvironmentName
    Environment containing the connector
.PARAMETER Filter
    Filter connectors by name or display name (wildcards supported)
.PARAMETER Environment
    Limit to connectors in a specific environment (for Filter mode)
.PARAMETER FilterNonCustomConnectors
    Exclude Microsoft-built shared connectors
.PARAMETER ReturnConnectorSwagger
    Include Swagger and runtime URLs (requires ConnectorName)
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-Connector.ps1 -PACredential $cred -Filter "SharePoint"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Filter")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Connector")]
    [Parameter(Mandatory = $true, ParameterSetName = "Filter")]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true, ParameterSetName = "Connector")]
    [string]$ConnectorName,

    [Parameter(Mandatory = $true, ParameterSetName = "Connector")]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true, ParameterSetName = "Filter")]
    [string]$Filter,

    [Parameter(ParameterSetName = "Filter")]
    [switch]$FilterNonCustomConnectors,

    [Parameter(ParameterSetName = "Connector")]
    [switch]$ReturnConnectorSwagger,

    [Parameter(ParameterSetName = "Filter")]
    [string]$Environment,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Connector")]
    [string]$ApiVersion,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Connector")]
    [ValidateSet('*', 'DisplayName', 'ConnectorName', 'ConnectorId', 'EnvironmentName', 'CreatedTime', 'Description', 'ApiDefinitions', 'Publisher', 'Source', 'Tier', 'Url', 'ChangedTime', 'ConnectionParameters', 'Swagger', 'WadlUrl', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'Description', 'ConnectorName', 'ConnectorId', 'EnvironmentName', 'ChangedTime')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSCmdlet.ParameterSetName -eq "Connector") {
            $getArgs.Add('ConnectorName', $ConnectorName)
            $getArgs.Add('EnvironmentName', $EnvironmentName)
            if ($PSBoundParameters.ContainsKey('ReturnConnectorSwagger')) { $getArgs.Add('ReturnConnectorSwagger', $ReturnConnectorSwagger) }
        }
        else {
            $getArgs.Add('Filter', $Filter)
            if ($PSBoundParameters.ContainsKey('Environment')) { $getArgs.Add('EnvironmentName', $Environment) }
            if ($PSBoundParameters.ContainsKey('FilterNonCustomConnectors')) { $getArgs.Add('FilterNonCustomConnectors', $FilterNonCustomConnectors) }
        }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }

        $result = Get-PowerAppConnector @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
