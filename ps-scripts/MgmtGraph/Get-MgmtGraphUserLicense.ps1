#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Audits license assignments for a Microsoft Graph user

.DESCRIPTION
    Retrieves detailed license assignment information for a specifies Microsoft Graph user, including SKU IDs and active service plans.

.PARAMETER Identity
    Specifies the UserPrincipalName or ID of the user to audit.

.EXAMPLE
    PS> ./Get-MgmtGraphUserLicense.ps1 -Identity "user@example.com"

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Identity
)

Process {
    try {
        $licenses = Get-MgUserLicenseDetail -UserId $Identity -All -ErrorAction Stop
        
        $results = foreach ($lic in $licenses) {
            [PSCustomObject]@{
                SkuId         = $lic.SkuId
                SkuPartNumber = $lic.SkuPartNumber
                ServicePlans  = $lic.ServicePlans | ForEach-Object { $_.ServicePlanName }
                Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
