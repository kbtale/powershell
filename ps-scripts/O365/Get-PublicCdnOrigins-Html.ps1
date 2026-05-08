#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of public CDN origins
.DESCRIPTION
    Generates an HTML report of public CDN origin configuration.
.EXAMPLE
    PS> ./Get-PublicCdnOrigins-Html.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOPublicCdnOrigins -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}