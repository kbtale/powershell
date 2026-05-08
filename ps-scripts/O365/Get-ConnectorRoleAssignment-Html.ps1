#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of connector role assignments
.DESCRIPTION
    Generates an HTML report of connector role assignments.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-ConnectorRoleAssignment-Html.ps1 -PACredential $cred | Out-File roles.html
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
        $result = Get-AdminPowerAppConnectorRoleAssignment -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
