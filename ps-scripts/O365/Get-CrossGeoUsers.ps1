#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets cross-geo users
.DESCRIPTION
    Returns SharePoint Online users in a multi-geo tenant matching specified criteria.
.PARAMETER ValidDataLocation
    Filter by valid data location status
.EXAMPLE
    PS> ./Get-CrossGeoUsers.ps1 -ValidDataLocation $true
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
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}