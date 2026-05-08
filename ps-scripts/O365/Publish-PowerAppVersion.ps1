#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.PowerShell

<#
.SYNOPSIS
    PowerApps: Publishes a PowerApp version
.DESCRIPTION
    Publishes the current draft version of an app as the live version.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER AppName
    The app identifier
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Publish-PowerAppVersion.ps1 -PACredential $cred -AppName "my-app"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$AppName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps4Creators -PAFCredential $PACredential
        $getArgs = @{ ErrorAction = 'Stop'; AppName = $AppName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $getArgs.Add('ApiVersion', $ApiVersion) }
        $result = Publish-PowerApp @getArgs -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps4Creators }
}
