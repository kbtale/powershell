#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves all groups

.DESCRIPTION
    Retrieves all Azure Active Directory groups with optional search filtering.

.PARAMETER SearchString
    Optional search string to filter groups by display name

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
        $groups = Get-AzureADGroup -All $true -SearchString $SearchString -ErrorAction Stop
        if ($null -ne $groups) {
            $groups = $groups | Sort-Object -Property DisplayName
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
        else {
            Write-Output "No groups found"
        }
    }
    catch {
        throw
    }
}
