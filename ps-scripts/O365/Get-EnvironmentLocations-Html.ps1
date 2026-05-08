#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of environment locations
.DESCRIPTION
    Generates an HTML report of available environment locations.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-EnvironmentLocations-Html.ps1 -PACredential $cred | Out-File locations.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $result = Get-AdminPowerAppEnvironmentLocations -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
