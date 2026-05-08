#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Retrieves PowerApp versions
.DESCRIPTION
    Returns all versions of an app with optional latest draft/published filtering.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER LatestDraft
    Return only the latest draft version
.PARAMETER LatestPublished
    Return only the latest published version
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Get-PowerAppVersion.ps1 -PACredential $cred -AppName "my-app"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [switch]$LatestDraft,
    [switch]$LatestPublished,
    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop'; AppName = $AppName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        if ($PSBoundParameters.ContainsKey('LatestDraft')) { $getArgs.Add('LatestDraft', $LatestDraft) }
        if ($PSBoundParameters.ContainsKey('LatestPublished')) { $getArgs.Add('LatestPublished', $LatestPublished) }
        $result = Get-PowerAppVersion @getArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
