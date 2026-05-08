#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of tenant graph details
.DESCRIPTION
    Generates an HTML report of tenant graph details.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-TenantGraphDetails-Html.ps1 -PACredential $cred | Out-File tenant.html
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
        $result = Get-TenantDetailsFromGraph -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
