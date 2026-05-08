#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of geo administrators
.DESCRIPTION
    Generates an HTML report of geo administrators for a multi-geo tenant.
.EXAMPLE
    PS> ./Get-GeoAdministrator-Html.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOGeoAdministrator -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}