#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of CDS database currencies
.DESCRIPTION
    Generates an HTML report of available CDS database currencies.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-CdsDatabaseCurrencies-Html.ps1 -PACredential $cred | Out-File currencies.html
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
        $result = Get-AdminPowerAppCdsDatabaseCurrencies -ErrorAction Stop | Select-Object * | Sort-Object CurrencyName
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
