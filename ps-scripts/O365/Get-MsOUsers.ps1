#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Get users from Azure AD
.DESCRIPTION
    Retrieves a list of users from Azure AD with optional filters.
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
    PS> ./Get-MsOUsers.ps1
.EXAMPLE
    PS> ./Get-MsOUsers.ps1 -OnlyUnlicensedUsers
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

        $result = Get-MsolUser @getArgs | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No users found"; return }
        foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force }
    }
    catch { throw }
}
