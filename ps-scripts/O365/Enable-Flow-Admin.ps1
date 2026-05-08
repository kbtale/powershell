#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Enables or disables a flow
.DESCRIPTION
    Toggles the enabled status of a flow in the tenant.
.PARAMETER PACredential
    PowerApps credentials
.PARAMETER FlowName
    Flow name identifier
.PARAMETER Enable
    Enable or disable the flow
.PARAMETER EnvironmentName
    The flow's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Enable-Flow-Admin.ps1 -PACredential $cred -FlowName "my-flow" -Enable $true
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
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; FlowName = $FlowName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        if ($Enable) { $null = Enable-AdminFlow @args -ErrorAction Stop }
        else { $null = Disable-AdminFlow @args -ErrorAction Stop }
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; FlowName = $FlowName; Enabled = $Enable.ToString(); Message = "Flow '$FlowName' enabled status: $Enable" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
