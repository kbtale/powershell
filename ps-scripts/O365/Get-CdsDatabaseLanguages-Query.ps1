#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: Query returns CDS database languages
.DESCRIPTION
    Returns CDS language codes as Value/DisplayValue pairs for use in selection dialogs.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-CdsDatabaseLanguages-Query.ps1 -PACredential $cred
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
        $result = Get-AdminPowerAppCdsDatabaseLanguages -ErrorAction Stop | Select-Object LanguageName, LanguageId | Sort-Object LanguageName
        foreach ($item in $result) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $item.LanguageId; DisplayValue = $item.LanguageName }
        }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
