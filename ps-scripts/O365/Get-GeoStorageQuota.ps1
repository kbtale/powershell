#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets geo storage quota
.DESCRIPTION
    Returns storage quotas for a multi-geo tenant.
.PARAMETER AllLocations
    Show quotas for all geo locations
.EXAMPLE
    PS> ./Get-GeoStorageQuota.ps1 -AllLocations
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
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
