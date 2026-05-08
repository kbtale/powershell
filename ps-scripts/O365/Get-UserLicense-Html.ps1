#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: HTML report of a user's licenses
.DESCRIPTION
    Generates an HTML report of license SKUs assigned to a specific user.
.PARAMETER UserObjectId
    UPN or ObjectId of the user
.EXAMPLE
    PS> ./Get-UserLicense-Html.ps1 -UserObjectId "john.doe@contoso.com" | Out-File userlicenses.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UserObjectId
)

Process {
    try {
        $licenses = Get-AzureADUserLicenseDetail -ObjectId $UserObjectId -ErrorAction Stop | Select-Object SkuId, SkuPartNumber

        Write-Output ($licenses | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
