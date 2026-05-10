#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Removes a user from the tenant
.DESCRIPTION
    Deletes a user account from Azure Active Directory identified by object ID or display name/UPN.
.PARAMETER UserObjectId
    Unique object ID of the user to remove
.PARAMETER UserName
    Display name or user principal name of the user to remove
.EXAMPLE
    PS> ./Remove-User.ps1 -UserName "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "UserName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "UserObjectId")]
    [guid]$UserObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "UserName")]
    [string]$UserName
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

        $null = Remove-AzureADUser -ObjectId $usr.ObjectID -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Status      = "Success"
            DisplayName = $usr.DisplayName
            ObjectId    = $usr.ObjectID
            Message     = "User '$($usr.DisplayName)' removed"
        }
    }
    catch { throw }
}
