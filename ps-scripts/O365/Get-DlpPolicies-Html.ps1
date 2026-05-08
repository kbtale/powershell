#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of DLP policies
.DESCRIPTION
    Generates an HTML report of Data Loss Prevention policies.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-DlpPolicies-Html.ps1 -PACredential $cred | Out-File dlp.html
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
        $result = Get-AdminDlpPolicy -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
