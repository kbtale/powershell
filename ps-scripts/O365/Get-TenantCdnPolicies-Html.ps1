#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of tenant CDN policies
.DESCRIPTION
    Generates an HTML report of CDN policies applied on the tenant.
.PARAMETER CdnType
    CDN type: Public or Private
.EXAMPLE
    PS> ./Get-TenantCdnPolicies-Html.ps1 -CdnType "Public"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private')]
    [string]$CdnType
)

Process {
    try {
        $result = Get-SPOTenantCdnPolicies -CdnType $CdnType -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}