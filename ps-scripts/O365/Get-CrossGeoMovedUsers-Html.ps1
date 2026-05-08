#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of cross-geo moved users
.DESCRIPTION
    Generates an HTML report of users that have been moved in a multi-geo tenant.
.PARAMETER Direction
    Movement direction: MoveIn or MoveOut
.EXAMPLE
    PS> ./Get-CrossGeoMovedUsers-Html.ps1 -Direction "MoveIn"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('MoveIn','MoveOut')]
    [string]$Direction
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Direction = $Direction }
        $result = Get-SPOCrossGeoMovedUsers @cmdArgs | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}