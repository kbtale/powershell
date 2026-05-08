#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves flow owner roles
.DESCRIPTION
    Gets owner permission assignments for one or more flows.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER FlowName
    Specifies the flow ID
.PARAMETER EnvironmentName
    The environment of the flow
.PARAMETER PrincipalObjectId
    Principal object ID of the user or security group
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-FlowOwnerRole.ps1 -PACredential $cred -FlowName "my-flow"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$FlowName,
    [string]$EnvironmentName,
    [string]$PrincipalObjectId,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $setArgs = @{ ErrorAction = 'Stop' }

        if ($PSBoundParameters.ContainsKey('FlowName')) { $setArgs.Add('FlowName', $FlowName) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $setArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('PrincipalObjectId')) { $setArgs.Add('PrincipalObjectId', $PrincipalObjectId) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $setArgs.Add('ApiVersion', $ApiVersion) }

        $result = Get-FlowOwnerRole @setArgs -ErrorAction Stop | Select-Object *

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
