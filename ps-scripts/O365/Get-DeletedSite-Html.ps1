#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of deleted sites
.DESCRIPTION
    Generates an HTML report of sites in the recycle bin.
.EXAMPLE
    PS> ./Get-DeletedSite-Html.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPODeletedSite -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}