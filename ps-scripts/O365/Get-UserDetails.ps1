#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves user details
.DESCRIPTION
    Returns details about PowerApps users.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER UserId
    Filter by user object ID or email
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-UserDetails.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$UserId,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('UserId')) { $args.Add('UserId', $UserId) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Get-AdminPowerAppsUserDetails @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
