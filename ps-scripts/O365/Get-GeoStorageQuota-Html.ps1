#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of geo storage quotas
.DESCRIPTION
    Generates an HTML report of storage quotas for a multi-geo tenant.
.PARAMETER AllLocations
    Show quotas for all geo locations
.EXAMPLE
    PS> ./Get-GeoStorageQuota-Html.ps1 -AllLocations
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$AllLocations
)

Process {
    try {
        if ($AllLocations) { $result = Get-SPOGeoStorageQuota -AllLocations -ErrorAction Stop | Select-Object * }
        else { $result = Get-SPOGeoStorageQuota -ErrorAction Stop | Select-Object * }
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}