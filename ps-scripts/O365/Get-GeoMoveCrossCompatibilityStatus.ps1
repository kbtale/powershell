#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets geo move cross-compatibility status
.DESCRIPTION
    Returns compatibility status for cross-geo moves.
.EXAMPLE
    PS> ./Get-GeoMoveCrossCompatibilityStatus.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOGeoMoveCrossCompatibilityStatus -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
