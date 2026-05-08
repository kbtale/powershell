#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Enables or disables CDN
.DESCRIPTION
    Enables or disables public or private content delivery network on the tenant level.
.PARAMETER CdnType
    CDN type: Public, Private, or Both
.PARAMETER Enable
    Enable or disable the CDN
.PARAMETER NoDefaultOrigins
    Do not include default origins
.EXAMPLE
    PS> ./Set-TenantCdnEnabled.ps1 -CdnType "Public" -Enable $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private','Both')]
    [string]$CdnType,
    [bool]$Enable,
    [switch]$NoDefaultOrigins
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; NoDefaultOrigins = $NoDefaultOrigins; Enable = $Enable; CdnType = $CdnType; Confirm = $false }
        $result = Set-SPOTenantCdnEnabled @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}