#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets CDN policies
.DESCRIPTION
    Retrieves the public or private CDN policies applied on the tenant.
.PARAMETER CdnType
    CDN type: Public or Private
.EXAMPLE
    PS> ./Get-TenantCdnPolicies.ps1 -CdnType "Public"
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
        $result = Get-SPOTenantCdnPolicies -CdnType $CdnType -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}