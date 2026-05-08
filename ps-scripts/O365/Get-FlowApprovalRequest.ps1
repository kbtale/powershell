#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves flow approval requests
.DESCRIPTION
    Returns approval requests assigned to the current user with optional filtering.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER Filter
    Find approvals matching a filter (wildcards supported)
.PARAMETER EnvironmentName
    Environment containing the approval
.PARAMETER Top
    Limit the result count
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-FlowApprovalRequest.ps1 -PACredential $cred -Top 25
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$Filter,
    [string]$EnvironmentName,
    [int]$Top = 50,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential

        $cmdArgs = @{
            ErrorAction = 'Stop'
            Top         = $Top
        }

        if ($PSBoundParameters.ContainsKey('Filter')) { $cmdArgs.Add('Filter', $Filter) }
        if ($PSBoundParameters.ContainsKey('EnvironmentName')) { $cmdArgs.Add('EnvironmentName', $EnvironmentName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $cmdArgs.Add('ApiVersion', $ApiVersion) }

        $result = Get-FlowApprovalRequest @cmdArgs -ErrorAction Stop | Select-Object *

        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
