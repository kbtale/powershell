#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves environments
.DESCRIPTION
    Returns PowerApps environments with optional filtering by name or default.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER EnvironmentName
    Find a specific environment
.PARAMETER Filter
    Filter by environment name (wildcards)
.PARAMETER Default
    Return only the default environment
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve
.EXAMPLE
    PS> ./Get-Environment.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$EnvironmentName,
    [string]$Filter,
    [switch]$Default,
    [string]$ApiVersion,

    [ValidateSet('*', 'DisplayName', 'EnvironmentName', 'IsDefault', 'CreatedTime', 'CreatedBy', 'Location', 'LastModifiedTime', 'LastModifiedBy', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'EnvironmentName', 'IsDefault', 'Location', 'LastModifiedTime')
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('Filter')) { $args.Add('Filter', $Filter) }
        elseif ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        elseif ($Default) { $args.Add('Default', $true) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Get-AdminPowerAppEnvironment @args -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
