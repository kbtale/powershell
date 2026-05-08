#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Sets a flow owner role
.DESCRIPTION
    Assigns owner permissions to a flow.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER FlowName
    Flow name identifier
.PARAMETER PrincipalObjectId
    Principal object ID to assign ownership
.PARAMETER RoleName
    Role to assign: CanEdit, CanView
.PARAMETER EnvironmentName
    The flow's environment
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-FlowOwnerRole.ps1 -PACredential $cred -FlowName "my-flow" -PrincipalObjectId "guid" -RoleName CanEdit
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

    [Parameter(Mandatory = $true)]
    [ValidateSet('CanEdit', 'CanView')]
    [string]$RoleName,

    [string]$EnvironmentName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; FlowName = $FlowName; PrincipalObjectId = $PrincipalObjectId; RoleName = $RoleName }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $args.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-FlowOwnerRole @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
