#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a CDN origin
.DESCRIPTION
    Removes an origin from the public or private content delivery network.
.PARAMETER CdnType
    CDN type: Public or Private
.PARAMETER OriginUrl
    Path to the document library to remove from CDN
.EXAMPLE
    PS> ./Remove-TenantCdnOrigin.ps1 -CdnType "Public" -OriginUrl "/sites/mysite/CDN"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private')]
    [string]$CdnType,
    [Parameter(Mandatory = $true)]
    [string]$OriginUrl
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; OriginUrl = $OriginUrl; CdnType = $CdnType; Confirm = $false }
        Remove-SPOTenantCdnOrigin @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "CDN origin '$OriginUrl' removed from '$CdnType'" }
    }
    catch { throw }
}