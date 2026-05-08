#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Assigns licenses to a user
.DESCRIPTION
    Assigns one or more license SKUs to a user by SKU ID or SKU Part Number.
.PARAMETER UserObjectId
    UPN or ObjectId of the user
.PARAMETER LicenseSkuIds
    Comma-separated list of license SKU GUIDs to assign
.PARAMETER LicenseSkuNames
    Comma-separated list of license SKU part numbers to assign
.EXAMPLE
    PS> ./Set-UserLicense.ps1 -UserObjectId "john.doe@contoso.com" -LicenseSkuNames "ENTERPRISEPACK"
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
        $assignedLicenses.AddLicenses = New-Object 'System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.AssignedLicense]'

        if ($PSCmdlet.ParameterSetName -eq 'ByNames') {
            foreach ($name in $LicenseSkuNames.Split(',')) {
                $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
                $license.SkuId = (Get-AzureADSubscribedSku -ErrorAction Stop | Where-Object -Property SkuPartNumber -Value $name -EQ).SkuID
                $assignedLicenses.AddLicenses.Add($license)
            }
        }
        else {
            foreach ($id in $LicenseSkuIds.Split(',')) {
                $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
                $license.SkuId = $id
                $assignedLicenses.AddLicenses.Add($license)
            }
        }

        $null = Set-AzureADUserLicense -ObjectId $UserObjectId -AssignedLicenses $assignedLicenses -ErrorAction Stop

        $result = Get-AzureADUserLicenseDetail -ObjectId $UserObjectId -ErrorAction Stop | Select-Object SkuId, SkuPartNumber
        if ($null -ne $result) {
            foreach ($item in $result) {
                $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
            }
        }
    }
    catch { throw }
}
