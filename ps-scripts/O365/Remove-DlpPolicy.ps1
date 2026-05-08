#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Removes a DLP policy
.DESCRIPTION
    Deletes a Data Loss Prevention policy.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER PolicyName
    The policy to remove
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Remove-DlpPolicy.ps1 -PACredential $cred -PolicyName "My DLP Policy"
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
        Remove-AdminDlpPolicy @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "DLP policy '$PolicyName' removed" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
