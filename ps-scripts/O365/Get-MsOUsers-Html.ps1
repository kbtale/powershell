#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: HTML report of Azure AD users
.DESCRIPTION
    Generates an HTML report with users from Azure AD.
.PARAMETER HasErrorsOnly
    Only users with validation errors
.PARAMETER OnlyDeletedUsers
    Only users in recycle bin
.PARAMETER OnlyUnlicensedUsers
    Only users without a license
.PARAMETER LicenseReconciliationNeededOnly
    Only users needing license reconciliation
.PARAMETER Filter
    Filter by enablement status
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOUsers-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MsOUsers-Html.ps1 -OnlyUnlicensedUsers | Out-File report.html
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$HasErrorsOnly,
    [switch]$OnlyDeletedUsers,
    [switch]$OnlyUnlicensedUsers,
    [switch]$LicenseReconciliationNeededOnly,
    [ValidateSet('All','EnabledOnly','DisabledOnly')]
    [string]$Filter = 'All',
    [guid]$TenantId
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'TenantId' = $TenantId}
        if ($HasErrorsOnly) { $getArgs.Add('HasErrorsOnly', $true) }
        if ($OnlyDeletedUsers) { $getArgs.Add('ReturnDeletedUsers', $true) }
        if ($OnlyUnlicensedUsers) { $getArgs.Add('UnlicensedUsersOnly', $true) }
        if ($LicenseReconciliationNeededOnly) { $getArgs.Add('LicenseReconciliationNeededOnly', $true) }
        if ($Filter -ne 'All') { $getArgs.Add('EnabledFilter', $Filter) }

        $result = Get-MsolUser @getArgs | Select-Object DisplayName, UserPrincipalName, Department, Title, ObjectId, IsLicensed
        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No users found"; return }
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
