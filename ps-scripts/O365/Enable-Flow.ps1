#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Enables or disables a flow
.DESCRIPTION
    Enables or disables a specific flow in a PowerApps environment.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER FlowName
    Identifier of the flow (not display name)
.PARAMETER Enable
    Enable or disable the flow
.PARAMETER EnvironmentName
    Environment containing the flow
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Enable-Flow.ps1 -PACredential $cred -FlowName "my-flow" -Enable $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$FlowName,

    [Parameter(Mandatory = $true)]
    [bool]$Enable,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $cmdArgs = @{
            ErrorAction = 'Stop'
            FlowName    = $FlowName
        }

        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $cmdArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $cmdArgs.Add('ApiVersion', $ApiVersion) }

        if ($Enable) { Enable-Flow @cmdArgs -ErrorAction Stop }
        else { Disable-Flow @cmdArgs -ErrorAction Stop }

        $result = Get-Flow @cmdArgs -ErrorAction Stop | Select-Object DisplayName, FlowName, Enabled, EnvironmentName, LastModifiedTime

        if ($null -ne $result) {
            $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
