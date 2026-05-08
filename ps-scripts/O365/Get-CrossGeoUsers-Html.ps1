#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of cross-geo users
.DESCRIPTION
    Generates an HTML report of users in a multi-geo tenant.
.PARAMETER ValidDataLocation
    Filter by valid data location status
.EXAMPLE
    PS> ./Get-CrossGeoUsers-Html.ps1
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [bool]$ValidDataLocation
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; ValidDataLocation = $ValidDataLocation }
        $result = Get-SPOCrossGeoUsers @cmdArgs | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}