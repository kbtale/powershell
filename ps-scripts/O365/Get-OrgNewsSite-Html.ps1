#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of org news sites
.DESCRIPTION
    Generates an HTML report of organization news site configuration.
.EXAMPLE
    PS> ./Get-OrgNewsSite-Html.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOOrgNewsSite -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}