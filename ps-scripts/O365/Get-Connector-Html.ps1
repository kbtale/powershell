#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of connectors
.DESCRIPTION
    Generates an HTML report of custom connectors.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-Connector-Html.ps1 -PACredential $cred | Out-File connectors.html
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
        $result = Get-AdminPowerAppConnector -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
