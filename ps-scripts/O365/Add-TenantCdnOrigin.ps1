#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Adds a CDN origin to the tenant
.DESCRIPTION
    Configures a new origin for the public or private content delivery network.
.PARAMETER CdnType
    CDN type: Public or Private
.PARAMETER OriginUrl
    Path to the document library to configure, e.g. /sites/site/subfolder
.EXAMPLE
    PS> ./Add-TenantCdnOrigin.ps1 -CdnType "Public" -OriginUrl "/sites/mysite/CDN"
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
        $result = Add-SPOTenantCdnOrigin @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}