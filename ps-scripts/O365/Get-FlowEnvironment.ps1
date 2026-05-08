#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves flow environments
.DESCRIPTION
    Returns information about Flow environments the user has access to, with optional filtering.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER EnvironmentName
    Find a specific environment by name
.PARAMETER Filter
    Find environments by wildcard filter
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-FlowEnvironment.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$EnvironmentName,
    [string]$Filter,
    [string]$ApiVersion,

    [ValidateSet('*', 'DisplayName', 'EnvironmentName', 'IsDefault', 'CreatedTime', 'CreatedBy', 'LastModifiedTime', 'LastModifiedBy', 'Location', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'EnvironmentName', 'IsDefault', 'LastModifiedTime', 'LastModifiedBy')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSBoundParameters.ContainsKey('Filter')) {
            $getArgs.Add('Filter', $Filter)
        }
        elseif ($PSBoundParameters.ContainsKey('EnvironmentName')) {
            $getArgs.Add('EnvironmentName', $EnvironmentName)
        }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }

        $result = Get-FlowEnvironment @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
