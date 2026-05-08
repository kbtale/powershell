#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets cross-geo moved users
.DESCRIPTION
    Returns SharePoint Online users that have been moved in a multi-geo tenant.
.PARAMETER Direction
    Movement direction: MoveIn or MoveOut
.EXAMPLE
    PS> ./Get-CrossGeoMovedUsers.ps1 -Direction "MoveIn"
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
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}