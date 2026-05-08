#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Query returns environment locations
.DESCRIPTION
    Returns environment location names as Value/DisplayValue pairs for use in selection dialogs.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-EnvironmentLocations-Query.ps1 -PACredential $cred
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
        $result = Get-AdminPowerAppEnvironmentLocations -ErrorAction Stop | Select-Object LocationDisplayName, LocationName | Sort-Object LocationDisplayName
        foreach ($item in $result) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $item.LocationName; DisplayValue = $item.LocationDisplayName }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
