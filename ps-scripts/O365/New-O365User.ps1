#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Creates a new user account
.DESCRIPTION
    Creates a new user in Azure AD with optional property assignments.
.PARAMETER UserPrincipalName
    UPN for the new user
.PARAMETER Password
    Password for the new user (secure string)
.PARAMETER DisplayName
    Display name of the user
.PARAMETER Enabled
    Whether the account is enabled for sign-in
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
    Mobile phone number of the user
.PARAMETER Department
    Department of the user
.PARAMETER ForceChangePasswordNextLogin
    Forces password change on next sign-in
.PARAMETER ShowInAddressList
    Show this user in the address list
.PARAMETER UserType
    Type of user: Member or Guest
.EXAMPLE
    PS> ./New-User.ps1 -UserPrincipalName "jane@contoso.com" -DisplayName "Jane Doe" -Password (Read-Host -AsSecureString) -Enabled $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [securestring]$Password,

    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [string]$FirstName,
    [string]$LastName,
    [string]$PostalCode,
    [string]$City,
    [string]$Street,
    [string]$PhoneNumber,
    [string]$MobilePhone,
    [string]$Department,
    [bool]$ForceChangePasswordNextLogin,
    [bool]$ShowInAddressList,

    [ValidateSet('Member', 'Guest')]
    [string]$UserType = 'Member'
)

Process {
    try {
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = $Password
        $PasswordProfile.ForceChangePasswordNextLogin = $ForceChangePasswordNextLogin

        $nick = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))

        $user = New-AzureADUser -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName -AccountEnabled $Enabled -MailNickName $nick -UserType $UserType -PasswordProfile $PasswordProfile -ShowInAddressList $ShowInAddressList -ErrorAction Stop | Select-Object *

        if ($null -eq $user) { throw "User not created" }

        if ($PSBoundParameters.ContainsKey('FirstName')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -GivenName $FirstName -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('LastName')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -Surname $LastName -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('PostalCode')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -PostalCode $PostalCode -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('City')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -City $City -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('Street')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -StreetAddress $Street -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('PhoneNumber')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -TelephoneNumber $PhoneNumber -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('MobilePhone')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -Mobile $MobilePhone -ErrorAction Stop }
        if ($PSBoundParameters.ContainsKey('Department')) { $null = Set-AzureADUser -ObjectId $user.ObjectId -Department $Department -ErrorAction Stop }

        $createdUser = Get-AzureADUser -ErrorAction Stop | Where-Object { $_.UserPrincipalName -eq $UserPrincipalName } | Select-Object *

        [PSCustomObject]@{
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status            = "Success"
            ObjectId          = $createdUser.ObjectId
            UserPrincipalName = $createdUser.UserPrincipalName
            DisplayName       = $createdUser.DisplayName
        }
    }
    catch { throw }
}
