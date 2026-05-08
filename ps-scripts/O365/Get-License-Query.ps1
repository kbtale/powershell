#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Query-format list of subscribed license SKUs
.DESCRIPTION
    Returns all subscribed license SKUs as Value/DisplayValue pairs for use in dropdown selectors.
.EXAMPLE
    PS> ./Get-License-Query.ps1
.CATEGORY O365
#>

Process {
    try {
        $licenses = Get-AzureADSubscribedSku -ErrorAction Stop | Select-Object SkuId, SkuPartNumber | Sort-Object -Property SkuPartNumber

        foreach ($item in $licenses) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $item.SkuId
                DisplayValue = $item.SkuPartNumber
            }
        }
    }
    catch { throw }
}
