#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves PowerApps information
.DESCRIPTION
    Returns information about PowerApps by name or filter criteria.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    Find a specific app by name
.PARAMETER EnvironmentName
    Limit to a specific environment
.PARAMETER Filter
    Find apps by wildcard filter
.PARAMETER MyEditable
    Show only apps the user can edit (requires EnvironmentName)
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-PowerApp.ps1 -PACredential $cred -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Filter")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Filter")]
    [Parameter(Mandatory = $true, ParameterSetName = "Name")]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true, ParameterSetName = "Name")]
    [string]$AppName,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Name")]
    [string]$ApiVersion,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Name")]
    [string]$EnvironmentName,

    [Parameter(ParameterSetName = "Filter")]
    [string]$Filter,

    [Parameter(ParameterSetName = "Filter")]
    [switch]$MyEditable,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Name")]
    [ValidateSet('*', 'DisplayName', 'AppName', 'EnvironmentName', 'CreatedTime', 'LastModifiedTime', 'UnpublishedAppDefinition', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'AppName', 'EnvironmentName', 'LastModifiedTime')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSCmdlet.ParameterSetName -eq "Name") { $getArgs.Add('AppName', $AppName) }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('Filter')) { $getArgs.Add('Filter', $Filter) }
        if ($PSBoundParameters.ContainsKey('MyEditable')) { $getArgs.Add('MyEditable', $null) }

        $result = Get-PowerApp @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
