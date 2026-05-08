#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets public CDN origins
.DESCRIPTION
    Returns the public CDN origin configuration.
.EXAMPLE
    PS> ./Get-PublicCdnOrigins.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOPublicCdnOrigins -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
