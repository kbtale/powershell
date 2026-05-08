#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Query-format list of all groups
.DESCRIPTION
    Returns all Azure AD groups as Value/DisplayValue pairs for use in dropdown selectors.
.EXAMPLE
    PS> ./Get-Group-Query.ps1
.CATEGORY O365
#>

Process {
    try {
        $groups = Get-AzureADGroup -All $true -ErrorAction Stop | Sort-Object DisplayName
        foreach ($grp in $groups) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $grp.ObjectId
                DisplayValue = $grp.DisplayName
            }
        }
    }
    catch { throw }
}
