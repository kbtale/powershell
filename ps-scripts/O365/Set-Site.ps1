#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets or updates site collection properties
.DESCRIPTION
    Configures one or more property values for a SharePoint Online site collection.
.PARAMETER Identity
    URL of the site collection to update
.PARAMETER Title
    Title of the site collection
.PARAMETER Owner
    Owner of the site collection
.PARAMETER StorageQuota
    Storage quota in megabytes
.PARAMETER SharingCapability
    Sharing capability level for the site
.PARAMETER LockState
    Lock state on the site
.PARAMETER NoWait
    Continue executing immediately
.EXAMPLE
    PS> ./Set-Site.ps1 -Identity "https://contoso.sharepoint.com/sites/MySite" -Title "New Title"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [string]$Title,
    [ValidateSet('ExternalUserAndGuestSharing','Disabled','ExternalUserSharingOnly','ExistingExternalUserSharingOnly')]
    [string]$SharingCapability,
    [ValidateSet('NoAccess','ReadOnly','Unlock')]
    [string]$LockState,
    [string]$Owner,
    [int64]$StorageQuota,
    [int64]$StorageQuotaWarningLevel,
    [switch]$NoWait,
    [bool]$AllowEditing,
    [bool]$DenyAddAndCustomizePages,
    [bool]$CommentsOnSitePagesDisabled,
    [bool]$SocialBarOnSitePagesDisabled,
    [ValidateSet('None','View','Edit')]
    [string]$DefaultLinkPermission,
    [ValidateSet('None','AnonymousAccess','Internal','Direct')]
    [string]$DefaultSharingLinkType,
    [string]$SharingAllowedDomainList,
    [string]$SharingBlockedDomainList,
    [ValidateSet('None','AllowList','BlockList')]
    [string]$SharingDomainRestrictionMode,
    [ValidateSet('AllowFullAccess','AllowLimitedAccess','BlockAccess')]
    [string]$ConditionalAccessPolicy,
    [uint32]$LocaleId,
    [bool]$DisableFlows,
    [ValidateSet('Unknown','Check','Disabled','Enabled')]
    [string]$SandboxedCodeActivationCapability,
    [double]$ResourceQuota,
    [double]$ResourceQuotaWarningLevel,
    [switch]$DisableSharingForNonOwners,
    [switch]$RemoveLabel,
    [switch]$StorageQuotaReset
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Confirm = $false; Identity = $Identity }
        if ($PSBoundParameters.ContainsKey('AllowEditing')) { $cmdArgs.Add('AllowEditing', $AllowEditing) }
        if ($PSBoundParameters.ContainsKey('ConditionalAccessPolicy')) { $cmdArgs.Add('ConditionalAccessPolicy', $ConditionalAccessPolicy) }
        if ($PSBoundParameters.ContainsKey('CommentsOnSitePagesDisabled')) { $cmdArgs.Add('CommentsOnSitePagesDisabled', $CommentsOnSitePagesDisabled) }
        if ($PSBoundParameters.ContainsKey('DefaultLinkPermission')) { $cmdArgs.Add('DefaultLinkPermission', $DefaultLinkPermission) }
        if ($PSBoundParameters.ContainsKey('DefaultSharingLinkType')) { $cmdArgs.Add('DefaultSharingLinkType', $DefaultSharingLinkType) }
        if ($PSBoundParameters.ContainsKey('DenyAddAndCustomizePages')) { $cmdArgs.Add('DenyAddAndCustomizePages', $DenyAddAndCustomizePages) }
        if ($PSBoundParameters.ContainsKey('DisableFlows')) { $cmdArgs.Add('DisableFlows', $DisableFlows) }
        if ($PSBoundParameters.ContainsKey('DisableSharingForNonOwners')) { $cmdArgs.Add('DisableSharingForNonOwners', $DisableSharingForNonOwners) }
        if ($PSBoundParameters.ContainsKey('LockState')) { $cmdArgs.Add('LockState', $LockState) }
        if ($PSBoundParameters.ContainsKey('NoWait')) { $cmdArgs.Add('NoWait', $NoWait) }
        if ($PSBoundParameters.ContainsKey('Owner')) { $cmdArgs.Add('Owner', $Owner) }
        if ($PSBoundParameters.ContainsKey('RemoveLabel')) { $cmdArgs.Add('RemoveLabel', $RemoveLabel) }
        if ($PSBoundParameters.ContainsKey('SandboxedCodeActivationCapability')) { $cmdArgs.Add('SandboxedCodeActivationCapability', $SandboxedCodeActivationCapability) }
        if ($PSBoundParameters.ContainsKey('SharingAllowedDomainList')) { $cmdArgs.Add('SharingAllowedDomainList', $SharingAllowedDomainList) }
        if ($PSBoundParameters.ContainsKey('SharingBlockedDomainList')) { $cmdArgs.Add('SharingBlockedDomainList', $SharingBlockedDomainList) }
        if ($PSBoundParameters.ContainsKey('SharingCapability')) { $cmdArgs.Add('SharingCapability', $SharingCapability) }
        if ($PSBoundParameters.ContainsKey('SharingDomainRestrictionMode')) { $cmdArgs.Add('SharingDomainRestrictionMode', $SharingDomainRestrictionMode) }
        if ($PSBoundParameters.ContainsKey('SocialBarOnSitePagesDisabled')) { $cmdArgs.Add('SocialBarOnSitePagesDisabled', $SocialBarOnSitePagesDisabled) }
        if ($PSBoundParameters.ContainsKey('StorageQuotaReset')) { $cmdArgs.Add('StorageQuotaReset', $StorageQuotaReset) }
        if ($PSBoundParameters.ContainsKey('Title')) { $cmdArgs.Add('Title', $Title) }
        if ($LocaleId -gt 0) { $cmdArgs.Add('LocaleId', $LocaleId) }
        if ($ResourceQuota -gt 0) { $cmdArgs.Add('ResourceQuota', $ResourceQuota) }
        if ($ResourceQuotaWarningLevel -gt 0) { $cmdArgs.Add('ResourceQuotaWarningLevel', $ResourceQuotaWarningLevel) }
        if ($StorageQuota -gt 0) { $cmdArgs.Add('StorageQuota', $StorageQuota) }
        if ($StorageQuotaWarningLevel -gt 0) { $cmdArgs.Add('StorageQuotaWarningLevel', $StorageQuotaWarningLevel) }
        $result = Set-SPOSite @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}