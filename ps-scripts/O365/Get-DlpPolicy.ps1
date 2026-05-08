#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves DLP policies
.DESCRIPTION
    Returns Data Loss Prevention policies with optional filtering.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER PolicyName
    Find a specific policy by name
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-DlpPolicy.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$PolicyName,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('PolicyName')) { $args.Add('PolicyName', $PolicyName) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Get-AdminDlpPolicy @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
