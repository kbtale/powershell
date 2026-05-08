#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets organization properties
.DESCRIPTION
    Returns SharePoint Online organization-level configuration properties.
.PARAMETER Properties
    List of properties to return; use * for all properties
.EXAMPLE
    PS> ./Get-Tenant.ps1
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
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}