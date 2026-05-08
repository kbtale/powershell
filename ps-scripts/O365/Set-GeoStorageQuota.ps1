#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets geo storage quota
.DESCRIPTION
    Updates the storage quota for a geo location.
.PARAMETER GeoLocation
    Geo location to update
.PARAMETER StorageQuotaMB
    Storage quota in MB
.EXAMPLE
    PS> ./Set-GeoStorageQuota.ps1 -GeoLocation "EUR" -StorageQuotaMB 524288
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GeoLocation,
    [Parameter(Mandatory = $true)]
    [long]$StorageQuotaMB
)

Process {
    try {
        $result = Set-SPOGeoStorageQuota -GeoLocation $GeoLocation -StorageQuotaMB $StorageQuotaMB -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
