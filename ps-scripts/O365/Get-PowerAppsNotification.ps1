#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves PowerApps notifications
.DESCRIPTION
    Returns notifications for the calling user.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER UserId
    Return notifications for a specific user
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-PowerAppsNotification.ps1 -PACredential $cred
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
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('UserId')) { $getArgs.Add('UserId', $UserId) }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        $result = Get-PowerAppsNotification @getArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
