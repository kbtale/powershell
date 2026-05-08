#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Query site collections
.DESCRIPTION
    Returns a query-friendly list of site collections with value/display pairs.
.PARAMETER Limit
    Maximum number of site collections to return
.EXAMPLE
    PS> ./Get-Sites-Query.ps1 -Limit 200
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [int]$Limit = 200
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Limit = $Limit }
        $result = Get-SPOSite @cmdArgs | Select-Object Url, Title | Sort-Object Title
        foreach ($item in $result) {
            [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Value = $item.Url; DisplayValue = $item.Title }
        }
    }
    catch { throw }
}