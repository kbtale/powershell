#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of tenant settings
.DESCRIPTION
    Generates an HTML report of PowerApps tenant settings.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-TenantSettings-Html.ps1 -PACredential $cred | Out-File tenantsettings.html
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
        $result = Get-AdminTenantSettings -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
