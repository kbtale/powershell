#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets CDN origins
.DESCRIPTION
    Lists all configured CDN origins under the tenancy.
.PARAMETER CdnType
    CDN type: Public or Private
.EXAMPLE
    PS> ./Get-TenantCdnOrigins.ps1 -CdnType "Public"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private')]
    [string]$CdnType
)

Process {
    try {
        $result = Get-SPOTenantCdnOrigins -CdnType $CdnType -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}