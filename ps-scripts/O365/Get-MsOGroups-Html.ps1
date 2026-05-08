#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: HTML report of Azure AD groups
.DESCRIPTION
    Generates an HTML report with groups from Azure AD.
.PARAMETER IsAgentRole
    Only agent groups
.PARAMETER HasLicenseErrorsOnly
    Only security groups with license errors
.PARAMETER HasErrorsOnly
    Only groups with validation errors
.PARAMETER GroupType
    Type of groups to retrieve
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Get-MsOGroups-Html.ps1 | Out-File report.html
.EXAMPLE
    PS> ./Get-MsOGroups-Html.ps1 -GroupType "Security" | Out-File report.html
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

        $result = Get-MsolGroup @getArgs -GroupType $GroupType | Select-Object DisplayName, EmailAddress, ObjectId, GroupType
        if ($null -eq $result -or $result.Count -eq 0) { Write-Output "No groups found"; return }
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
