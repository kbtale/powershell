#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves information about flows
.DESCRIPTION
    Returns flow details by name or by filter criteria including My/Team scoping.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER FlowName
    Find a specific flow by name
.PARAMETER Filter
    Filter flows by display name (wildcards supported)
.PARAMETER My
    Show only flows owned by the authenticated user
.PARAMETER Team
    Show flows owned by user but shared with others
.PARAMETER Top
    Limit the result count
.PARAMETER EnvironmentName
    Limit to a specific environment
.PARAMETER ApiVersion
    API version to call
.PARAMETER Properties
    Properties to retrieve. Use * for all.
.EXAMPLE
    PS> ./Get-Flow.ps1 -PACredential $cred -My
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Filter")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Filter")]
    [Parameter(Mandatory = $true, ParameterSetName = "Flow")]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true, ParameterSetName = "Flow")]
    [string]$FlowName,

    [Parameter(ParameterSetName = "Filter")]
    [string]$Filter,

    [Parameter(ParameterSetName = "Filter")]
    [switch]$My,

    [Parameter(ParameterSetName = "Filter")]
    [switch]$Team,

    [Parameter(ParameterSetName = "Filter")]
    [int]$Top = 50,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Flow")]
    [string]$EnvironmentName,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Flow")]
    [string]$ApiVersion,

    [Parameter(ParameterSetName = "Filter")]
    [Parameter(ParameterSetName = "Flow")]
    [ValidateSet('*', 'DisplayName', 'FlowName', 'Enabled', 'EnvironmentName', 'CreatedTime', 'LastModifiedTime', 'UserType', 'Internal')]
    [string[]]$Properties = @('DisplayName', 'FlowName', 'Enabled', 'EnvironmentName', 'LastModifiedTime')
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{ ErrorAction = 'Stop' }

        if ($PSCmdlet.ParameterSetName -eq "Filter") {
            if ($My) { $getArgs.Add('My', $true) }
            if ($Team) { $getArgs.Add('Team', $true) }
        }
        else { $getArgs.Add('FlowName', $FlowName) }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('Filter')) { $getArgs.Add('Filter', $Filter) }
        if ($PSBoundParameters.ContainsKey('Top')) { $getArgs.Add('Top', $Top) }

        $result = Get-Flow @getArgs -ErrorAction Stop | Select-Object $Properties

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
