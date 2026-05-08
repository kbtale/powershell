#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Updates a DLP policy
.DESCRIPTION
    Modifies an existing Data Loss Prevention policy.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER PolicyName
    The policy to update
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-DlpPolicy.ps1 -PACredential $cred -PolicyName "My DLP Policy"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$PolicyName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; PolicyName = $PolicyName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminDlpPolicy @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
