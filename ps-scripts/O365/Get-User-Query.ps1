#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Query-format list of all users
.DESCRIPTION
    Returns all Azure AD users as Value/DisplayValue pairs for use in dropdown selectors.
.EXAMPLE
    PS> ./Get-User-Query.ps1
.CATEGORY O365
#>

Process {
    try {
        $users = Get-AzureADUser -All $true -ErrorAction Stop | Select-Object DisplayName, UserPrincipalName -Unique | Sort-Object -Property DisplayName

        foreach ($usr in $users) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $usr.UserPrincipalName
                DisplayValue = $usr.DisplayName
            }
        }
    }
    catch { throw }
}
