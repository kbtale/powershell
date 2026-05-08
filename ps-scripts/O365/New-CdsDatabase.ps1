#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Creates a CDS database
.DESCRIPTION
    Creates a Common Data Service database for an environment.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER EnvironmentName
    The environment to provision
.PARAMETER LocationName
    Geographic location for the database
.PARAMETER CurrencyName
    Currency code for the database
.PARAMETER LanguageName
    Language name for the database
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./New-CdsDatabase.ps1 -PACredential $cred -EnvironmentName "default" -LocationName "unitedstates" -CurrencyName "USD" -LanguageName "1033"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [Parameter(Mandatory = $true)]
    [string]$EnvironmentName,

    [Parameter(Mandatory = $true)]
    [string]$LocationName,

    [Parameter(Mandatory = $true)]
    [string]$CurrencyName,

    [Parameter(Mandatory = $true)]
    [string]$LanguageName,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop'; EnvironmentName = $EnvironmentName; LocationName = $LocationName; CurrencyName = $CurrencyName; LanguageName = $LanguageName }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $result = New-AdminPowerAppCdsDatabase @args -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
