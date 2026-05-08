#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Reset Azure AD user password
.DESCRIPTION
    Resets the password for an Azure AD user. Supports forcing password change on next sign-in.
.PARAMETER UserObjectId
    Unique ID of the user
.PARAMETER UserName
    Display name, Sign-In Name or UPN of the user
.PARAMETER NewPassword
    New password for the user (SecureString)
.PARAMETER ForceChangePassword
    User must change the password on next sign-in
.PARAMETER ForceChangePasswordOnly
    Require password change without setting a new password
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Reset-MsOUserPassword.ps1 -UserName "user@domain.com" -NewPassword (Read-Host -AsSecureString)
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
    [string]$UserName,
    [Parameter(ParameterSetName = 'Id')]
    [Parameter(ParameterSetName = 'Name')]
    [securestring]$NewPassword,
    [Parameter(ParameterSetName = 'Id')]
    [Parameter(ParameterSetName = 'Name')]
    [switch]$ForceChangePassword,
    [Parameter(Mandatory = $true, ParameterSetName = 'ForceOnly')]
    [switch]$ForceChangePasswordOnly,
    [Parameter(ParameterSetName = 'Id')]
    [Parameter(ParameterSetName = 'Name')]
    [guid]$TenantId
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq 'Id') { $user = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId -ErrorAction Stop }
        elseif ($PSCmdlet.ParameterSetName -eq 'Name') { $user = Get-MsolUser -SearchString $UserName -TenantId $TenantId -ErrorAction Stop | Select-Object -First 1 }
        else { $user = $null }

        if ($ForceChangePasswordOnly -and $user) {
            Set-MsolUserPassword -ObjectId $user.ObjectId -ForceChangePassword $true -ForceChangePasswordOnly $true -TenantId $TenantId -ErrorAction Stop
        }
        elseif ($null -ne $NewPassword -and $user) {
            $plainPass = (New-Object System.Net.NetworkCredential('', $NewPassword)).Password
            Set-MsolUserPassword -ObjectId $user.ObjectId -NewPassword $plainPass -ForceChangePassword:$ForceChangePassword -TenantId $TenantId -ErrorAction Stop
        }

        [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; UserName = if ($user) { $user.UserPrincipalName } else { $UserName }; Status = 'Password reset completed' }
    }
    catch { throw }
}
