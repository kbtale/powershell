#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: HTML report of subscribed license SKUs
.DESCRIPTION
    Generates an HTML report of all subscribed Azure AD license SKUs.
.EXAMPLE
    PS> ./Get-License-Html.ps1 | Out-File licenses.html
.CATEGORY O365
#>

Process {
    try {
        $licenses = Get-AzureADSubscribedSku -ErrorAction Stop | Select-Object SkuId, SkuPartNumber, AppliesTo, CapabilityStatus, ConsumedUnits, ObjectId | Sort-Object -Property SkuPartNumber

        Write-Output ($licenses | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
