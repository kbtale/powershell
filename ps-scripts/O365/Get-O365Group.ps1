#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Lists all groups in the tenant
.DESCRIPTION
    Retrieves all Azure Active Directory groups with optional search filtering by display name.
.PARAMETER SearchString
    Optional string to filter groups by display name
.EXAMPLE
    PS> ./Get-Group.ps1 -SearchString "Sales"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$SearchString
)

Process {
    try {
        $groups = Get-AzureADGroup -All $true -SearchString $SearchString -ErrorAction Stop | Sort-Object -Property DisplayName

        if ($null -eq $groups -or $groups.Count -eq 0) {
            Write-Output "No groups found"
            return
        }

        foreach ($grp in $groups) {
            [PSCustomObject]@{
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                DisplayName = $grp.DisplayName
                Description = $grp.Description
                Mail        = $grp.Mail
                ObjectId    = $grp.ObjectId
                ObjectType  = $grp.ObjectType
            }
        }
    }
    catch { throw }
}
