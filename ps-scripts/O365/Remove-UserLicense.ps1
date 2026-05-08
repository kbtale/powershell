#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Removes license assignments from a user
.DESCRIPTION
    Removes specified license SKUs from a user by SKU ID or SKU Part Number.
.PARAMETER UserObjectId
    UPN or ObjectId of the user
.PARAMETER LicenseSkuIds
    Comma-separated list of license SKU GUIDs to remove
.PARAMETER LicenseSkuNames
    Comma-separated list of license SKU part numbers to remove
.EXAMPLE
    PS> ./Remove-UserLicense.ps1 -UserObjectId "john.doe@contoso.com" -LicenseSkuNames "ENTERPRISEPACK"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "ByNames")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'ByIds')]
    [Parameter(Mandatory = $true, ParameterSetName = 'ByNames')]
    [string]$UserObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByIds')]
    [string]$LicenseSkuIds,

    [Parameter(Mandatory = $true, ParameterSetName = 'ByNames')]
    [string]$LicenseSkuNames
)

Process {
    try {
        $assignedLicenses = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $assignedLicenses.RemoveLicenses = New-Object 'System.Collections.Generic.List[string]'

        if ($PSCmdlet.ParameterSetName -eq 'ByNames') {
            foreach ($name in $LicenseSkuNames.Split(',')) {
                $skuId = (Get-AzureADSubscribedSku -ErrorAction Stop | Where-Object -Property SkuPartNumber -Value $name -EQ).SkuID
                $assignedLicenses.RemoveLicenses.Add($skuId)
            }
        }
        else {
            foreach ($id in $LicenseSkuIds.Split(',')) {
                $assignedLicenses.RemoveLicenses.Add($id)
            }
        }

        $null = Set-AzureADUserLicense -ObjectId $UserObjectId -AssignedLicenses $assignedLicenses -ErrorAction Stop

        $remaining = Get-AzureADUserLicenseDetail -ObjectId $UserObjectId -ErrorAction Stop | Select-Object SkuId, SkuPartNumber
        if ($null -ne $remaining) {
            foreach ($item in $remaining) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
}
