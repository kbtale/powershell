#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    PowerApps: Query returns principal object IDs
.DESCRIPTION
    Returns Azure AD principal object IDs and display names as Value/DisplayValue pairs.
.EXAMPLE
    PS> ./Get-PrincipalObjectIds-Query.ps1
.CATEGORY O365
#>

Process {
    try {
        $users = Get-AzureADUser -All $true -ErrorAction Stop | Select-Object DisplayName, ObjectID | Sort-Object -Property Displayname
        foreach ($item in $users) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $item.ObjectID; DisplayValue = $item.DisplayName }
        }
    }
    catch { throw }
}
