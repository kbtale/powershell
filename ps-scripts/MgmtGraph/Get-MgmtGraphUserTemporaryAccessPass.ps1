#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.SignIns

<#
.SYNOPSIS
    MgmtGraph: Audits Temporary Access Passes for a Microsoft Graph user

.DESCRIPTION
    Retrieves the list of active Temporary Access Pass (TAP) authentication methods for a specifies user, including expiry times and usage status.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserTemporaryAccessPass.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $taps = Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $Identity -All -ErrorAction Stop
        
        $results = foreach ($t in $taps) {
            [PSCustomObject]@{
                UserIdentity = $Identity
                Id           = $t.Id
                StartDateTime = $t.StartDateTime
                LifetimeInMinutes = $t.LifetimeInMinutes
                IsUsableOnce = $t.IsUsableOnce
                IsUsable     = $t.IsUsable
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
