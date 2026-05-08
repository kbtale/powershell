#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves subscribed license SKUs from the tenant
.DESCRIPTION
    Lists all Azure AD subscribed SKU licenses with their IDs, part numbers, consumed units and status.
.EXAMPLE
    PS> ./Get-License.ps1
.CATEGORY O365
#>

Process {
    try {
        $licenses = Get-AzureADSubscribedSku -ErrorAction Stop | Select-Object SkuId, SkuPartNumber, AppliesTo, CapabilityStatus, ConsumedUnits, ObjectId | Sort-Object -Property SkuPartNumber

        foreach ($item in $licenses) {
            [PSCustomObject]@{
                Timestamp        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                SkuId            = $item.SkuId
                SkuPartNumber    = $item.SkuPartNumber
                AppliesTo        = $item.AppliesTo
                CapabilityStatus = $item.CapabilityStatus
                ConsumedUnits    = $item.ConsumedUnits
                ObjectId         = $item.ObjectId
            }
        }
    }
    catch { throw }
}
