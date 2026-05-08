#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Resets a user's password
.DESCRIPTION
    Sets a new password for an Azure AD user with optional force-change-on-next-login flag.
.PARAMETER UserObjectId
    Unique object ID of the user
.PARAMETER UserName
    Display name or UPN of the user
.PARAMETER NewPassword
    New password for the user (secure string)
.PARAMETER ForceChangePasswordNextLogin
    Forces the user to change password on next sign-in
.EXAMPLE
    PS> ./Reset-UserPassword.ps1 -UserName "john.doe@contoso.com" -NewPassword (Read-Host -AsSecureString)
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "UserName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [guid]$UserObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "UserName")]
    [string]$UserName,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [securestring]$NewPassword,

    [Parameter(ParameterSetName = "UserName")]
    [Parameter(ParameterSetName = "UserObjectId")]
    [bool]$ForceChangePasswordNextLogin
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "UserObjectId") {
            $usr = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop | Select-Object *
        }
        else {
            $usr = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName) } | Select-Object *
        }

        if ($null -eq $usr) { throw "User not found" }

        if ($PSBoundParameters.ContainsKey('ForceChangePasswordNextLogin')) {
            $null = Set-AzureADUserPassword -ObjectId $usr.ObjectID -Password $NewPassword -ForceChangePasswordNextLogin $ForceChangePasswordNextLogin -ErrorAction Stop
        }
        else {
            $null = Set-AzureADUserPassword -ObjectId $usr.ObjectID -Password $NewPassword -ErrorAction Stop
        }

        [PSCustomObject]@{
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status      = "Success"
            DisplayName = $usr.DisplayName
            ObjectId    = $usr.ObjectID
            Message     = "Password reset for user '$($usr.DisplayName)'"
        }
    }
    catch { throw }
}
