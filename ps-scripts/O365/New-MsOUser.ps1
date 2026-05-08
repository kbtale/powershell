#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Create a user in Azure AD
.DESCRIPTION
    Creates a new user in Azure Active Directory using the MSOnline module.
.PARAMETER UserPrincipalName
    User ID for this user
.PARAMETER Password
    New password for the user
.PARAMETER DisplayName
    Display name of the user
.PARAMETER FirstName
    First name of the user
.PARAMETER LastName
    Last name of the user
.PARAMETER PostalCode
    Postal code of the user
.PARAMETER City
    City of the user
.PARAMETER Street
    Street address of the user
.PARAMETER PhoneNumber
    Phone number of the user
.PARAMETER MobilePhone
    Mobile phone number
.PARAMETER Department
    Department of the user
.PARAMETER Title
    Job title of the user
.PARAMETER Country
    Country of the user
.PARAMETER State
    State or province
.PARAMETER UsageLocation
    Usage location (ISO country code)
.PARAMETER ForceChangePassword
    User must change password on next sign-in
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./New-MsOUser.ps1 -UserPrincipalName "newuser@domain.com" -DisplayName "New User" -Password (Read-Host -AsSecureString)
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [securestring]$Password,
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [string]$FirstName,
    [string]$LastName,
    [string]$PostalCode,
    [string]$City,
    [string]$Street,
    [string]$PhoneNumber,
    [string]$MobilePhone,
    [string]$Department,
    [string]$Title,
    [string]$Country,
    [string]$State,
    [string]$UsageLocation,
    [switch]$ForceChangePassword,
    [guid]$TenantId
)

Process {
    try {
        [hashtable]$newArgs = @{'ErrorAction' = 'Stop'; 'UserPrincipalName' = $UserPrincipalName; 'DisplayName' = $DisplayName; 'TenantId' = $TenantId}
        if ($null -ne $Password) { $newArgs.Add('Password', (New-Object System.Net.NetworkCredential('', $Password)).Password) }
        if (-not [System.String]::IsNullOrWhiteSpace($FirstName)) { $newArgs.Add('FirstName', $FirstName) }
        if (-not [System.String]::IsNullOrWhiteSpace($LastName)) { $newArgs.Add('LastName', $LastName) }
        if (-not [System.String]::IsNullOrWhiteSpace($UsageLocation)) { $newArgs.Add('UsageLocation', $UsageLocation) }
        if ($ForceChangePassword) { $newArgs.Add('ForceChangePassword', $true) }

        $result = New-MsolUser @newArgs | Select-Object *
        if ($null -eq $result) { Write-Output "Failed to create user"; return }
        $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') -PassThru -Force
    }
    catch { throw }
}
