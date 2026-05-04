#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    MgmtGraph: Audits tenant license subscriptions (SKUs)

.DESCRIPTION
    Retrieves the list of all license subscriptions (SKUs) available in the Microsoft Graph tenant, including consumption and availability metadata.

.EXAMPLE
    PS> ./Get-MgmtGraphSubscribedSku.ps1

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $skus = Get-MgSubscribedSku -ErrorAction Stop
        
        $results = foreach ($s in $skus) {
            [PSCustomObject]@{
                SkuPartNumber = $s.SkuPartNumber
                SkuId         = $s.SkuId
                Consumed      = $s.ConsumedUnits
                Enabled       = $s.PrepaidUnits.Enabled
                Warning       = $s.PrepaidUnits.Warning
                Suspended     = $s.PrepaidUnits.Suspended
                Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object SkuPartNumber)
    }
    catch {
        throw
    }
}
