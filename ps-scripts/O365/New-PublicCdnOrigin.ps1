#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Adds a public CDN origin
.DESCRIPTION
    Adds a new origin to the public CDN configuration.
.PARAMETER OriginUrl
    The CDN origin URL to add
.EXAMPLE
    PS> ./New-PublicCdnOrigin.ps1 -OriginUrl "*/MASTERPAGE"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$OriginUrl
)

Process {
    try {
        $result = New-SPOPublicCdnOrigin -Url $OriginUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
