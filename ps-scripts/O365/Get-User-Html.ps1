#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: HTML report of all users
.DESCRIPTION
    Generates an HTML report of Azure AD users with optional search filtering.
.PARAMETER SearchString
    Optional string to filter users
.EXAMPLE
    PS> ./Get-User-Html.ps1 -SearchString "Doe" | Out-File users.html
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

        Write-Output ($users | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
