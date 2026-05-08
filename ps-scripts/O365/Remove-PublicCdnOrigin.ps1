#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a public CDN origin
.DESCRIPTION
    Deletes a CDN origin from the public CDN configuration.
.PARAMETER OriginUrl
    The CDN origin URL to remove
.EXAMPLE
    PS> ./Remove-PublicCdnOrigin.ps1 -OriginUrl "*/MASTERPAGE"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$OriginUrl
)

Process {
    try {
        Remove-SPOPublicCdnOrigin -Identity $OriginUrl -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "CDN origin '$OriginUrl' removed" }
    }
    catch { throw }
}
