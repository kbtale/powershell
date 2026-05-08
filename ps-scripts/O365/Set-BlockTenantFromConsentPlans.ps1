#Requires -Version 5.1
#Requires -Modules Microsoft.PowerApps.Administration.PowerShell

<#
.SYNOPSIS
    PowerApps Admin: Blocks tenant from consent plans
.DESCRIPTION
    Blocks the tenant from consent plans.
.PARAMETER PACredential
    PowerApps credentials for authentication
.PARAMETER ApiVersion
    API version to call
.EXAMPLE
    PS> ./Set-BlockTenantFromConsentPlans.ps1 -PACredential $cred
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$PACredential,

    [string]$ApiVersion
)

Process {
    try {
        ConnectPowerApps -PAFCredential $PACredential
        $args = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('ApiVersion')) { $args.Add('ApiVersion', $ApiVersion) }
        $null = Set-AdminPowerAppBlockTenantFromConsentPlans @args -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Tenant blocked from consent plans" }
    }
    catch { throw }
    finally { DisconnectPowerApps }
}
