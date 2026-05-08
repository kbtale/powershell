#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: HTML report of all groups
.DESCRIPTION
    Generates an HTML report of Azure AD groups with optional search filtering.
.PARAMETER SearchString
    Optional string to filter groups by display name
.EXAMPLE
    PS> ./Get-Group-Html.ps1 -SearchString "Sales" | Out-File groups.html
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

        $rows = foreach ($g in $groups) {
            [PSCustomObject]@{ DisplayName = $g.DisplayName; Description = $g.Description; Mail = $g.Mail; ObjectId = $g.ObjectId }
        }

        Write-Output ($rows | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
