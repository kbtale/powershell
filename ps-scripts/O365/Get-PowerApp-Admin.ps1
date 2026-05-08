#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves apps
.DESCRIPTION
    Returns information about apps with filtering by name, environment, or owner.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    Find a specific app by name
.PARAMETER Environment
    The app's environment (required for AppName lookup)
.PARAMETER Owner
    Filter by app owner (email or object ID)
.PARAMETER EnvironmentName
    Limit to apps in a specific environment
.PARAMETER Filter
    Find apps by wildcard filter
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-PowerApp-Admin.ps1 -PACredential $cred -EnvironmentName "default"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Filter")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Filter")]
    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [Parameter(Mandatory = $true, ParameterSetName = "App")]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true, ParameterSetName = "App")]
    [string]$AppName,

    [Parameter(Mandatory = $true, ParameterSetName = "App")]
    [string]$Environment,

    [Parameter(Mandatory = $true, ParameterSetName = "User")]
    [string]$Owner,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "App")]
    [Parameter(ParameterSetName = "User")]
    [string]$ApiVersion,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "User")]
    [string]$EnvironmentName,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "User")]
    [string]$Filter,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "User")]
    [Parameter(ParameterSetName = "App")]
    [ValidateSet('*', 'DisplayName', 'AppName', 'EnvironmentName', 'CreatedTime', 'LastModifiedTime', 'IsFeaturedApp', 'IsHeroApp', 'BypassConsent', 'Owner', 'UnpublishedAppDefinition', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'AppName', 'EnvironmentName', 'LastModifiedTime', 'Owner')
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSCmdlet.ParameterSetName -eq "App") { $getArgs.Add('AppName', $AppName); $getArgs.Add('EnvironmentName', $Environment) }
        elseif ($PSCmdlet.ParameterSetName -eq "User") { $getArgs.Add('Owner', $Owner) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('Filter')) { $getArgs.Add('Filter', $Filter) }
        $result = Get-AdminPowerApp @getArgs -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
