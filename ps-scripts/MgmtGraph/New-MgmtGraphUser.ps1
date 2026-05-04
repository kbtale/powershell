#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Users

<#
.SYNOPSIS
    MgmtGraph: Creates a new Microsoft Graph user account

.DESCRIPTION
    Provisions a new user account in the Microsoft Graph tenant with specifies identity details, password, and account status.

.PARAMETER DisplayName
    Specifies the display name for the user.

.PARAMETER UserPrincipalName
    Specifies the UserPrincipalName (e.g., user@domain.com) for the user.

.PARAMETER MailNickname
    Specifies the mail alias for the user.

.PARAMETER Password
    Specifies the initial password for the user as a SecureString.

.PARAMETER AccountEnabled
    If set to $true, the account will be enabled upon creation. Defaults to $false.

.PARAMETER GivenName
    Optional. Specifies the user's first name.

.PARAMETER Surname
    Optional. Specifies the user's last name.

.PARAMETER JobTitle
    Optional. Specifies the user's job title.

.PARAMETER Department
    Optional. Specifies the user's department.

.EXAMPLE
    PS> $secPass = Read-Host -AsSecureString
    PS> ./New-MgmtGraphUser.ps1 -DisplayName "Alice Green" -UserPrincipalName "alice.green@example.com" -MailNickname "aliceg" -Password $secPass -AccountEnabled $true

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,

    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [string]$MailNickname,

    [Parameter(Mandatory = $true)]
    [System.Security.SecureString]$Password,

    [bool]$AccountEnabled = $false,

    [string]$GivenName,

    [string]$Surname,

    [string]$JobTitle,

    [string]$Department
)

Process {
    try {
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))

        $params = @{
            'DisplayName'       = $DisplayName
            'UserPrincipalName' = $UserPrincipalName
            'MailNickname'      = $MailNickname
            'AccountEnabled'    = $AccountEnabled
            'PasswordProfile'   = @{ 'Password' = $plainPassword; 'ForceChangePasswordNextSignIn' = $true }
            'ErrorAction'       = 'Stop'
        }

        if ($GivenName) { $params.Add('GivenName', $GivenName) }
        if ($Surname) { $params.Add('Surname', $Surname) }
        if ($JobTitle) { $params.Add('JobTitle', $JobTitle) }
        if ($Department) { $params.Add('Department', $Department) }

        $user = New-MgUser @params
        
        $result = [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            Id                = $user.Id
            AccountEnabled    = $user.AccountEnabled
            Status            = "UserCreated"
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
