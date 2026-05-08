#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Enables or disables a user account
.DESCRIPTION
    Sets the enabled/disabled status of an Azure AD user account.
.PARAMETER UserObjectId
    Unique object ID of the user
.PARAMETER UserName
    Display name or UPN of the user
.PARAMETER Enabled
    Whether the account is enabled for sign-in
.EXAMPLE
    PS> ./Set-UserEnabledStatus.ps1 -UserName "john.doe@contoso.com" -Enabled $false
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "UserName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [guid]$UserObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "UserName")]
    [string]$UserName,

    [Parameter(Mandatory = $true, ParameterSetName = "UserName")]
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [bool]$Enabled
)

Process {
    try {
        if ($PSCmdlet.ParameterSetName -eq "UserObjectId") {
            $usr = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop | Select-Object ObjectID, DisplayName
        }
        else {
            $usr = Get-AzureADUser -All $true -ErrorAction Stop | Where-Object { ($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName) } | Select-Object ObjectID, DisplayName
        }

        if ($null -eq $usr) { throw "User not found" }

        $null = Set-AzureADUser -ObjectId $usr.ObjectId -AccountEnabled $Enabled -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status      = "Success"
            DisplayName = $usr.DisplayName
            ObjectId    = $usr.ObjectID
            Enabled     = $Enabled.ToString()
        }
    }
    catch { throw }
}
