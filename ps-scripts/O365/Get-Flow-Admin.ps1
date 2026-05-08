#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Retrieves flows
.DESCRIPTION
    Returns flows in the tenant with optional filtering.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER FlowName
    Find a specific flow by name
.PARAMETER EnvironmentName
    Limit to a specific environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-Flow-Admin.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$FlowName,
    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('FlowName')) { $args.Add('FlowName', $FlowName) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Get-AdminFlow @args -ErrorAction Stop | Select-Object DisplayName, FlowName, Enabled, EnvironmentName, LastModifiedTime
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
