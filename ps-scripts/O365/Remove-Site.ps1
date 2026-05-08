#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sends a site collection to the recycle bin
.DESCRIPTION
    Removes a SharePoint Online site collection and places it in the recycle bin.
.PARAMETER Identity
    URL of the site collection to remove
.PARAMETER NoWait
    Continue executing script immediately without waiting
.EXAMPLE
    PS> ./Remove-Site.ps1 -Identity "https://contoso.sharepoint.com/sites/MySite"
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
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity; NoWait = $NoWait; Confirm = $false }
        Remove-SPOSite @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site '$Identity' sent to recycle bin" }
    }
    catch { throw }
}