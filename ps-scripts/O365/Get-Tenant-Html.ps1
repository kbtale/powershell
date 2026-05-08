#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of organization properties
.DESCRIPTION
    Generates an HTML report of SharePoint Online organization properties.
.PARAMETER Properties
    List of properties to return; use * for all properties
.EXAMPLE
    PS> ./Get-Tenant-Html.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [ValidateSet('*','AllowEditing','PublicCdnAllowedFileTypes','ExternalServicesEnabled','StorageQuotaAllocated','ResourceQuotaAllocated','OneDriveStorageQuota')]
    [string[]]$Properties = @('AllowEditing','PublicCdnAllowedFileTypes','ExternalServicesEnabled','StorageQuotaAllocated','ResourceQuotaAllocated','OneDriveStorageQuota')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $result = Get-SPOTenant -ErrorAction Stop | Select-Object $Properties
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}