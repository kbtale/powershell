#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of connection role assignments
.DESCRIPTION
    Generates an HTML report of connection role assignments.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-ConnectionRoleAssignment-Html.ps1 -PACredential $cred | Out-File roles.html
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
        $result = Get-AdminPowerAppConnectionRoleAssignment -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
