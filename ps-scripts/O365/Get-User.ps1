#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Lists all users in the tenant
.DESCRIPTION
    Retrieves a filtered and sorted list of Azure AD users with essential identity properties.
.PARAMETER SearchString
    Optional string to filter users by display name or UPN
.EXAMPLE
    PS> ./Get-User.ps1 -SearchString "Doe"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$SearchString
)

Process {
    try {
        $users = Get-AzureADUser -All $true -SearchString $SearchString -ErrorAction Stop | Select-Object DisplayName, ObjectID, UserPrincipalName, AccountEnabled -Unique | Sort-Object -Property DisplayName

        if ($null -eq $users -or $users.Count -eq 0) {
            Write-Output "No users found"
            return
        }

        foreach ($usr in $users) {
            [PSCustomObject]@{
                Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                DisplayName       = $usr.DisplayName
                ObjectId          = $usr.ObjectID
                UserPrincipalName = $usr.UserPrincipalName
                AccountEnabled    = $usr.AccountEnabled
            }
        }
    }
    catch { throw }
}
