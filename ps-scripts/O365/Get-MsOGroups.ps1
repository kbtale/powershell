#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Get groups from Azure AD
.DESCRIPTION
    Retrieves groups from Azure Active Directory using the MSOnline module with optional filters.
.PARAMETER IsAgentRole
    Only agent groups (partner users only)
.PARAMETER HasLicenseErrorsOnly
    Only security groups with license errors
.PARAMETER HasErrorsOnly
    Only groups with validation errors
.PARAMETER GroupType
    Type of groups to retrieve
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOGroups.ps1
.EXAMPLE
    PS> ./Get-MsOGroups.ps1 -GroupType "Security"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$IsAgentRole,
    [switch]$HasLicenseErrorsOnly,
    [switch]$HasErrorsOnly,
    [ValidateSet('All','Security','MailEnabledSecurity','DistributionList')]
    [string]$GroupType = 'All',
    [guid]$TenantId
)

Process {
    try {
        [hashtable]$getArgs = @{'ErrorAction' = 'Stop'; 'TenantId' = $TenantId}
        if ($IsAgentRole) { $getArgs.Add('IsAgentRole', $true) }
        if ($HasLicenseErrorsOnly) { $getArgs.Add('HasLicenseErrorsOnly', $true) }
        if ($HasErrorsOnly) { $getArgs.Add('HasErrorsOnly', $true) }

        $result = Get-MsolGroup @getArgs -GroupType $GroupType | Select-Object *

        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No groups found"; return }
        foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force }
    }
    catch { throw }
}
