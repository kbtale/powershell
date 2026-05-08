#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps: HTML report of flow user details
.DESCRIPTION
    Generates an HTML report of users associated with a flow.
.PARAMETER PACredential
    PowerApps credentials
.EXAMPLE
    PS> ./Get-FlowUserDetails-Html.ps1 -PACredential $cred | Out-File flowusers.html
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
        $result = Get-AdminFlowUserDetails -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
