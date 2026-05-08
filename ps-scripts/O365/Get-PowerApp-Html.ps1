#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of PowerApps
.DESCRIPTION
    Generates an HTML report of PowerApps in the tenant.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-PowerApp-Html.ps1 -PACredential $cred | Out-File powerapps.html
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
        $result = Get-AdminPowerApp -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
