#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a flow owner role
.DESCRIPTION
    Removes owner permissions from a flow.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER FlowName
    Flow name identifier
.PARAMETER PrincipalObjectId
    Principal object ID to remove
.PARAMETER EnvironmentName
    The flow's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-FlowOwnerRole.ps1 -PACredential $cred -FlowName "my-flow" -PrincipalObjectId "guid"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$FlowName,

    [Parameter(Mandatory = $true)]
    [string]$PrincipalObjectId,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; FlowName = $FlowName; PrincipalObjectId = $PrincipalObjectId }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        Remove-FlowOwnerRole @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Flow owner role removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
