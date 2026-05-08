#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves connectors
.DESCRIPTION
    Returns custom connectors with optional filtering by name, environment, or creator.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER UserName
    Filter by connector creator email/ID
.PARAMETER CreatedBy
    Filter by creator email
.PARAMETER ConnectorName
    Find a specific connector
.PARAMETER EnvironmentName
    Limit to connectors in an environment
.PARAMETER Filter
    Filter by connector name (wildcards)
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve
.EXAMPLE
    PS> ./Get-Connector-Admin.ps1 -PACredential $cred -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Filter")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [Parameter(Mandatory = $true, ParameterSetName = "Connector")]
    [Parameter(Mandatory = $true, ParameterSetName = "Filter")]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [string]$UserName,

    [Parameter(ParameterSetName = "Filter")]
    [string]$CreatedBy,

    [Parameter(Mandatory = $true, ParameterSetName = "Connector")]
    [string]$ConnectorName,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Connector")]
    [Parameter(ParameterSetName = "User")]
    [string]$ApiVersion,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Connector")]
    [Parameter(ParameterSetName = "User")]
    [string]$EnvironmentName,

    [Parameter(ParameterSetName = "User")]
    [Parameter(ParameterSetName = "Filter")]
    [string]$Filter,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "User")]
    [Parameter(ParameterSetName = "Connector")]
    [ValidateSet('*', 'DisplayName', 'ConnectorName', 'ConnectorId', 'EnvironmentName', 'CreatedTime', 'CreatedBy', 'ApiDefinitions', 'LastModifiedTime', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'ConnectorName', 'ConnectorId', 'EnvironmentName', 'LastModifiedTime')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        ConnectPowerApps -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSCmdlet.ParameterSetName -eq "Connector") { $getArgs.Add('ConnectorName', $ConnectorName) }
        elseif ($PSCmdlet.ParameterSetName -eq "User") { $getArgs.Add('CreatedBy', $UserName) }
        elseif ($PSCmdlet.ParameterSetName -eq "Filter" -and $PSBoundParameters.ContainsKey('CreatedBy')) { $getArgs.Add('CreatedBy', $CreatedBy) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('Filter')) { $getArgs.Add('Filter', $Filter) }
        $result = Get-AdminPowerAppConnector @getArgs -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
