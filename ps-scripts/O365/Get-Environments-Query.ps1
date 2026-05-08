#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Query returns environments
.DESCRIPTION
    Returns environment names as Value/DisplayValue pairs for use in selection dialogs.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-Environments-Query.ps1 -PACredential $cred
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
        $result = Get-AdminPowerAppEnvironment -ErrorAction Stop | Select-Object EnvironmentName, DisplayName | Sort-Object DisplayName
        foreach ($item in $result) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $item.EnvironmentName; DisplayValue = $item.DisplayName }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
