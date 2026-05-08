#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets CDN policies
.DESCRIPTION
    Configures content delivery network policies at the tenant level.
.PARAMETER CdnType
    CDN type: Public or Private
.PARAMETER PolicyType
    Policy type to configure
.PARAMETER PolicyValue
    Policy value to set
.EXAMPLE
    PS> ./Set-TenantCdnPolicy.ps1 -CdnType "Public" -PolicyType "IncludeFileExtensions" -PolicyValue "CSS,EOT,GIF,ICO,JPEG,JPG,JS,MAP,PNG,SVG,TTF,WOFF"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private')]
    [string]$CdnType,
    [Parameter(Mandatory = $true)]
    [ValidateSet('IncludeFileExtensions','ExcludeRestrictedSiteClassifications','ExcludeIfNoScriptDisabled')]
    [string]$PolicyType,
    [Parameter(Mandatory = $true)]
    [string]$PolicyValue
)

Process {
    try {
        $result = Set-SPOTenantCdnPolicy -CdnType $CdnType -PolicyType $PolicyType -PolicyValue $PolicyValue -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}