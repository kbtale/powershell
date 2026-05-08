#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves a list of subscribed SKU licenses

.DESCRIPTION
    Retrieves a list of subscribed SKU licenses.

.EXAMPLE
    PS> ./Get-License.ps1

.CATEGORY O365
#>

Process {
    try {
        $result = Get-AzureADSubscribedSku -ErrorAction Stop | Select-Object @('SkuId', 'SkuPartNumber', 'AppliesTo', 'CapabilityStatus', 'ConsumedUnits', 'ObjectId') | Sort-Object -Property SkuPartNumber

        if ($null -ne $result) {
            foreach ($item in $result) {
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
    }
    catch {
        throw
    }
}
