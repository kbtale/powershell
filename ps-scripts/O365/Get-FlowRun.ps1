#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves flow run details
.DESCRIPTION
    Gets run details for a specified flow.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER FlowName
    Flow name identifier (not display name)
.PARAMETER EnvironmentName
    The environment of the flow
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-FlowRun.ps1 -PACredential $cred -FlowName "my-flow"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$FlowName,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $getArgs = @{
            ErrorAction = 'Stop'
            FlowName    = $FlowName
        }

        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $getArgs.Add('EnvironmentName', $EnvironmentName) }

        $result = Get-FlowRun @getArgs -ErrorAction Stop | Select-Object *

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
