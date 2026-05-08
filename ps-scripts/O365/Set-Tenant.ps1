#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets organization properties
.DESCRIPTION
    Configures tenant-level SharePoint Online organization properties.
.PARAMETER AllowEditing
    Prevents users from editing Office files in the browser
.PARAMETER ConditionalAccessPolicy
    Control access from unmanaged devices
.PARAMETER SharingCapability
    Determines what level of sharing is available
.PARAMETER OneDriveStorageQuota
    Default OneDrive for Business storage quota in MB
.PARAMETER PublicCdnEnabled
    Enable or disable the public CDN
.PARAMETER SocialBarOnSitePagesDisabled
    Disables or enables the social bar
.EXAMPLE
    PS> ./Set-Tenant.ps1 -SharingCapability "ExternalUserAndGuestSharing" -OneDriveStorageQuota 1048576
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [bool]$AllowEditing,
    [ValidateSet('AllowFullAccess','LimitedAccess','BlockAccess')]
    [string]$ConditionalAccessPolicy,
    [ValidateSet('OfficeOnlineFilesOnly','WebPreviewableFiles','OtherFiles')]
    [string]$LimitedAccessFileType,
    [bool]$ApplyAppEnforcedRestrictionsToAdHocRecipients,
    [bool]$BccExternalSharingInvitations,
    [string]$BccExternalSharingsInvitationList,
    [bool]$CommentsOnSitePagesDisabled,
    [string]$CustomizedExternalSharingServiceUrl,
    [ValidateSet('None','Direct','Internal','AnonymousAccess')]
    [string]$DefaultSharingLinkType,
    [string]$DisabledWebPartIds,
    [bool]$DisallowInfectedFileDownload,
    [bool]$DisplayStartASiteOption,
    [bool]$EnableAzureADB2BIntegration,
    [bool]$EnableGuestSignInAcceleration,
    [bool]$ExternalServicesEnabled,
    [ValidateSet('None','View','Edit')]
    [string]$FileAnonymousLinkType,
    [ValidateSet('None','View','Edit')]
    [string]$FolderAnonymousLinkType,
    [string]$IPAddressAllowList,
    [bool]$IPAddressEnforcement,
    [int]$IPAddressWACTokenLifetime,
    [bool]$LegacyAuthProtocolsEnabled = $true,
    [int]$MaxCompatibilityLevel,
    [int]$MinCompatibilityLevel,
    [string]$NoAccessRedirectUrl,
    [bool]$NotificationsInOneDriveForBusinessEnabled,
    [bool]$NotificationsInSharePointEnabled,
    [bool]$NotifyOwnersWhenInvitationsAccepted,
    [bool]$NotifyOwnersWhenItemsReshared,
    [ValidateSet('On','Off','Unspecified')]
    [string]$ODBAccessRequests,
    [ValidateSet('On','Off','Unspecified')]
    [string]$ODBMembersCanShare,
    [bool]$OfficeClientADALDisabled,
    [bool]$OneDriveForGuestsEnabled,
    [int64]$OneDriveStorageQuota,
    [bool]$OwnerAnonymousNotification,
    [bool]$PermissiveBrowserFileHandlingOverride,
    [bool]$PreventExternalUsersFromResharing,
    [bool]$ProvisionSharedWithEveryoneFolder,
    [string]$PublicCdnAllowedFileTypes,
    [bool]$PublicCdnEnabled,
    [bool]$RequireAcceptingAccountMatchInvitedAccount,
    [int]$RequireAnonymousLinksExpireInDays,
    [bool]$SearchResolveExactEmailOrUPN,
    [string]$SharingAllowedDomainList,
    [string]$SharingBlockedDomainList,
    [ValidateSet('ExternalUserAndGuestSharing','Disabled','ExternalUserSharingOnly')]
    [string]$SharingCapability,
    [ValidateSet('None','AllowList','BlockList')]
    [string]$SharingDomainRestrictionMode,
    [bool]$ShowAllUsersClaim,
    [bool]$ShowEveryoneClaim,
    [bool]$ShowEveryoneExceptExternalUsersClaim,
    [bool]$ShowPeoplePickerSuggestionsForGuestUsers,
    [string]$SignInAccelerationDomain,
    [bool]$SocialBarOnSitePagesDisabled,
    [ValidateSet('NoPreference','Allowed','Disallowed')]
    [string]$SpecialCharactersStateInFileFolderNames,
    [string]$StartASiteFormUrl,
    [bool]$UseFindPeopleInPeoplePicker,
    [bool]$UsePersistentCookiesForExplorerView,
    [bool]$UserVoiceForFeedbackEnabled
)

Process {
    try {
        $Properties = @('AllowEditing','PublicCdnAllowedFileTypes','ExternalServicesEnabled','StorageQuotaAllocated','ResourceQuotaAllocated','OneDriveStorageQuota')
        $cmdArgs = @{ ErrorAction = 'Stop'; LegacyAuthProtocolsEnabled = $LegacyAuthProtocolsEnabled }
        if ($PSBoundParameters.ContainsKey('AllowEditing')) { $cmdArgs.Add('AllowEditing', $AllowEditing) }
        if ($PSBoundParameters.ContainsKey('ApplyAppEnforcedRestrictionsToAdHocRecipients')) { $cmdArgs.Add('ApplyAppEnforcedRestrictionsToAdHocRecipients', $ApplyAppEnforcedRestrictionsToAdHocRecipients) }
        if ($PSBoundParameters.ContainsKey('BccExternalSharingInvitations')) { $cmdArgs.Add('BccExternalSharingInvitations', $BccExternalSharingInvitations) }
        if ($PSBoundParameters.ContainsKey('BccExternalSharingsInvitationList')) { $cmdArgs.Add('BccExternalSharingsInvitationList', $BccExternalSharingsInvitationList) }
        if ($PSBoundParameters.ContainsKey('CommentsOnSitePagesDisabled')) { $cmdArgs.Add('CommentsOnSitePagesDisabled', $CommentsOnSitePagesDisabled) }
        if ($PSBoundParameters.ContainsKey('ConditionalAccessPolicy')) { $cmdArgs.Add('ConditionalAccessPolicy', $ConditionalAccessPolicy) }
        if ($PSBoundParameters.ContainsKey('CustomizedExternalSharingServiceUrl')) { $cmdArgs.Add('CustomizedExternalSharingServiceUrl', $CustomizedExternalSharingServiceUrl) }
        if ($PSBoundParameters.ContainsKey('DefaultSharingLinkType')) { $cmdArgs.Add('DefaultSharingLinkType', $DefaultSharingLinkType) }
        if ($PSBoundParameters.ContainsKey('DisabledWebPartIds')) { $cmdArgs.Add('DisabledWebPartIds', $DisabledWebPartIds) }
        if ($PSBoundParameters.ContainsKey('DisallowInfectedFileDownload')) { $cmdArgs.Add('DisallowInfectedFileDownload', $DisallowInfectedFileDownload) }
        if ($PSBoundParameters.ContainsKey('DisplayStartASiteOption')) { $cmdArgs.Add('DisplayStartASiteOption', $DisplayStartASiteOption) }
        if ($PSBoundParameters.ContainsKey('EnableAzureADB2BIntegration')) { $cmdArgs.Add('EnableAzureADB2BIntegration', $EnableAzureADB2BIntegration) }
        if ($PSBoundParameters.ContainsKey('EnableGuestSignInAcceleration')) { $cmdArgs.Add('EnableGuestSignInAcceleration', $EnableGuestSignInAcceleration) }
        if ($PSBoundParameters.ContainsKey('ExternalServicesEnabled')) { $cmdArgs.Add('ExternalServicesEnabled', $ExternalServicesEnabled) }
        if ($PSBoundParameters.ContainsKey('FileAnonymousLinkType')) { $cmdArgs.Add('FileAnonymousLinkType', $FileAnonymousLinkType) }
        if ($PSBoundParameters.ContainsKey('FolderAnonymousLinkType')) { $cmdArgs.Add('FolderAnonymousLinkType', $FolderAnonymousLinkType) }
        if ($PSBoundParameters.ContainsKey('IPAddressAllowList')) { $cmdArgs.Add('IPAddressAllowList', $IPAddressAllowList) }
        if ($PSBoundParameters.ContainsKey('IPAddressEnforcement')) { $cmdArgs.Add('IPAddressEnforcement', $IPAddressEnforcement) }
        if ($PSBoundParameters.ContainsKey('LimitedAccessFileType')) { $cmdArgs.Add('LimitedAccessFileType', $LimitedAccessFileType) }
        if ($PSBoundParameters.ContainsKey('NoAccessRedirectUrl')) { $cmdArgs.Add('NoAccessRedirectUrl', $NoAccessRedirectUrl) }
        if ($PSBoundParameters.ContainsKey('NotificationsInOneDriveForBusinessEnabled')) { $cmdArgs.Add('NotificationsInOneDriveForBusinessEnabled', $NotificationsInOneDriveForBusinessEnabled) }
        if ($PSBoundParameters.ContainsKey('NotificationsInSharePointEnabled')) { $cmdArgs.Add('NotificationsInSharePointEnabled', $NotificationsInSharePointEnabled) }
        if ($PSBoundParameters.ContainsKey('NotifyOwnersWhenInvitationsAccepted')) { $cmdArgs.Add('NotifyOwnersWhenInvitationsAccepted', $NotifyOwnersWhenInvitationsAccepted) }
        if ($PSBoundParameters.ContainsKey('NotifyOwnersWhenItemsReshared')) { $cmdArgs.Add('NotifyOwnersWhenItemsReshared', $NotifyOwnersWhenItemsReshared) }
        if ($PSBoundParameters.ContainsKey('ODBAccessRequests')) { $cmdArgs.Add('ODBAccessRequests', $ODBAccessRequests) }
        if ($PSBoundParameters.ContainsKey('ODBMembersCanShare')) { $cmdArgs.Add('ODBMembersCanShare', $ODBMembersCanShare) }
        if ($PSBoundParameters.ContainsKey('OfficeClientADALDisabled')) { $cmdArgs.Add('OfficeClientADALDisabled', $OfficeClientADALDisabled) }
        if ($PSBoundParameters.ContainsKey('OneDriveForGuestsEnabled')) { $cmdArgs.Add('OneDriveForGuestsEnabled', $OneDriveForGuestsEnabled) }
        if ($PSBoundParameters.ContainsKey('OwnerAnonymousNotification')) { $cmdArgs.Add('OwnerAnonymousNotification', $OwnerAnonymousNotification) }
        if ($PSBoundParameters.ContainsKey('PermissiveBrowserFileHandlingOverride')) { $cmdArgs.Add('PermissiveBrowserFileHandlingOverride', $PermissiveBrowserFileHandlingOverride) }
        if ($PSBoundParameters.ContainsKey('PreventExternalUsersFromResharing')) { $cmdArgs.Add('PreventExternalUsersFromResharing', $PreventExternalUsersFromResharing) }
        if ($PSBoundParameters.ContainsKey('ProvisionSharedWithEveryoneFolder')) { $cmdArgs.Add('ProvisionSharedWithEveryoneFolder', $ProvisionSharedWithEveryoneFolder) }
        if ($PSBoundParameters.ContainsKey('PublicCdnAllowedFileTypes')) { $cmdArgs.Add('PublicCdnAllowedFileTypes', $PublicCdnAllowedFileTypes) }
        if ($PSBoundParameters.ContainsKey('PublicCdnEnabled')) { $cmdArgs.Add('PublicCdnEnabled', $PublicCdnEnabled) }
        if ($PSBoundParameters.ContainsKey('RequireAcceptingAccountMatchInvitedAccount')) { $cmdArgs.Add('RequireAcceptingAccountMatchInvitedAccount', $RequireAcceptingAccountMatchInvitedAccount) }
        if ($PSBoundParameters.ContainsKey('RequireAnonymousLinksExpireInDays')) { $cmdArgs.Add('RequireAnonymousLinksExpireInDays', $RequireAnonymousLinksExpireInDays) }
        if ($PSBoundParameters.ContainsKey('SearchResolveExactEmailOrUPN')) { $cmdArgs.Add('SearchResolveExactEmailOrUPN', $SearchResolveExactEmailOrUPN) }
        if ($PSBoundParameters.ContainsKey('SharingAllowedDomainList')) { $cmdArgs.Add('SharingAllowedDomainList', $SharingAllowedDomainList) }
        if ($PSBoundParameters.ContainsKey('SharingBlockedDomainList')) { $cmdArgs.Add('SharingBlockedDomainList', $SharingBlockedDomainList) }
        if ($PSBoundParameters.ContainsKey('SharingCapability')) { $cmdArgs.Add('SharingCapability', $SharingCapability) }
        if ($PSBoundParameters.ContainsKey('SharingDomainRestrictionMode')) { $cmdArgs.Add('SharingDomainRestrictionMode', $SharingDomainRestrictionMode) }
        if ($PSBoundParameters.ContainsKey('ShowAllUsersClaim')) { $cmdArgs.Add('ShowAllUsersClaim', $ShowAllUsersClaim) }
        if ($PSBoundParameters.ContainsKey('ShowEveryoneClaim')) { $cmdArgs.Add('ShowEveryoneClaim', $ShowEveryoneClaim) }
        if ($PSBoundParameters.ContainsKey('ShowEveryoneExceptExternalUsersClaim')) { $cmdArgs.Add('ShowEveryoneExceptExternalUsersClaim', $ShowEveryoneExceptExternalUsersClaim) }
        if ($PSBoundParameters.ContainsKey('ShowPeoplePickerSuggestionsForGuestUsers')) { $cmdArgs.Add('ShowPeoplePickerSuggestionsForGuestUsers', $ShowPeoplePickerSuggestionsForGuestUsers) }
        if ($PSBoundParameters.ContainsKey('SignInAccelerationDomain')) { $cmdArgs.Add('SignInAccelerationDomain', $SignInAccelerationDomain) }
        if ($PSBoundParameters.ContainsKey('SocialBarOnSitePagesDisabled')) { $cmdArgs.Add('SocialBarOnSitePagesDisabled', $SocialBarOnSitePagesDisabled) }
        if ($PSBoundParameters.ContainsKey('SpecialCharactersStateInFileFolderNames')) { $cmdArgs.Add('SpecialCharactersStateInFileFolderNames', $SpecialCharactersStateInFileFolderNames) }
        if ($PSBoundParameters.ContainsKey('StartASiteFormUrl')) { $cmdArgs.Add('StartASiteFormUrl', $StartASiteFormUrl) }
        if ($PSBoundParameters.ContainsKey('UseFindPeopleInPeoplePicker')) { $cmdArgs.Add('UseFindPeopleInPeoplePicker', $UseFindPeopleInPeoplePicker) }
        if ($PSBoundParameters.ContainsKey('UsePersistentCookiesForExplorerView')) { $cmdArgs.Add('UsePersistentCookiesForExplorerView', $UsePersistentCookiesForExplorerView) }
        if ($PSBoundParameters.ContainsKey('UserVoiceForFeedbackEnabled')) { $cmdArgs.Add('UserVoiceForFeedbackEnabled', $UserVoiceForFeedbackEnabled) }
        if ($IPAddressWACTokenLifetime -gt 0) { $cmdArgs.Add('IPAddressWACTokenLifetime', $IPAddressWACTokenLifetime) }
        if ($MaxCompatibilityLevel -gt 0) { $cmdArgs.Add('MaxCompatibilityLevel', $MaxCompatibilityLevel) }
        if ($MinCompatibilityLevel -gt 0) { $cmdArgs.Add('MinCompatibilityLevel', $MinCompatibilityLevel) }
        if ($OneDriveStorageQuota -gt 0) { $cmdArgs.Add('OneDriveStorageQuota', $OneDriveStorageQuota) }
        Set-SPOTenant @cmdArgs | Out-Null
        $result = Get-SPOTenant -ErrorAction Stop | Select-Object $Properties
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}