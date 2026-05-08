#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Updates tenant settings
.DESCRIPTION
    Modifies PowerApps tenant-level configuration settings.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-TenantSettings.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = Set-AdminTenantSettings @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
