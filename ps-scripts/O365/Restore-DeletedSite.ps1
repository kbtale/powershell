#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Restores a deleted site collection
.DESCRIPTION
    Restores a SharePoint Online site collection from the recycle bin.
.PARAMETER Identity
    URL of the deleted site collection to restore
.PARAMETER NoWait
    Continue executing script immediately without waiting
.EXAMPLE
    PS> ./Restore-DeletedSite.ps1 -Identity "https://contoso.sharepoint.com/sites/DeletedSite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [switch]$NoWait
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity; NoWait = $NoWait }
        Restore-SPODeletedSite @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site '$Identity' restored from recycle bin" }
    }
    catch { throw }
}