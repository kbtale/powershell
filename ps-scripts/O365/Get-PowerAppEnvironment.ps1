#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves PowerApps environments
.DESCRIPTION
    Returns PowerApps environments the user has access to, with optional filtering.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER EnvironmentName
    Find a specific environment
.PARAMETER Filter
    Find environments by wildcard filter
.PARAMETER CreatedByMe
    Show only environments created by the calling user
.PARAMETER Default
    Find the default environment
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-PowerAppEnvironment.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$EnvironmentName,
    [string]$Filter,
    [switch]$CreatedByMe,
    [switch]$Default,
    [string]$ApiVersion,

    [ValidateSet('*', 'DisplayName', 'EnvironmentName', 'Location', 'CreatedTime', 'CreatedBy', 'IsDefault', 'LastModifiedTime', 'LastModifiedBy', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'EnvironmentName', 'Location', 'LastModifiedTime', 'LastModifiedBy')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSBoundParameters.ContainsKey('Filter')) {
            $getArgs.Add('Filter', $Filter)
            $getArgs.Add('CreatedByMe', $CreatedByMe)
        }
        elseif ($PSBoundParameters.ContainsKey('EnvironmentName')) {
            $getArgs.Add('EnvironmentName', $EnvironmentName)
        }
        else { $getArgs.Add('Default', $Default) }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }

        $result = Get-PowerAppEnvironment @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
