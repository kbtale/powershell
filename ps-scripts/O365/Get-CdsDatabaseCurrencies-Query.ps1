#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Query returns CDS database currencies
.DESCRIPTION
    Returns CDS currency codes as Value/DisplayValue pairs for use in selection dialogs.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-CdsDatabaseCurrencies-Query.ps1 -PACredential $cred
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
        $result = Get-AdminPowerAppCdsDatabaseCurrencies -ErrorAction Stop | Select-Object CurrencyName, CurrencyId | Sort-Object CurrencyName
        foreach ($item in $result) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $item.CurrencyId; DisplayValue = $item.CurrencyName }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
