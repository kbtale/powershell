#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves license details for a user
.DESCRIPTION
    Gets the assigned license SKU IDs and part numbers for a specified user.
.PARAMETER UserObjectId
    UPN or ObjectId of the user in Azure AD
.EXAMPLE
    PS> ./Get-UserLicense.ps1 -UserObjectId "john.doe@contoso.com"
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

        if ($null -ne $licenses) {
            foreach ($item in $licenses) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
}
