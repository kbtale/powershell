#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of CDS database languages
.DESCRIPTION
    Generates an HTML report of available CDS database languages.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-CdsDatabaseLanguages-Html.ps1 -PACredential $cred | Out-File languages.html
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
        $result = Get-AdminPowerAppCdsDatabaseLanguages -ErrorAction Stop | Select-Object * | Sort-Object LanguageName
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
