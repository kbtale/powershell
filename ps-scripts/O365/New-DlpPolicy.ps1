#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Creates a DLP policy
.DESCRIPTION
    Creates a new Data Loss Prevention policy.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER PolicyName
    Name for the new policy
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./New-DlpPolicy.ps1 -PACredential $cred -PolicyName "My DLP Policy"
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
        $result = New-AdminDlpPolicy @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
