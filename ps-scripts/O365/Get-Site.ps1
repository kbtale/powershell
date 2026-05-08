#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets sites
.DESCRIPTION
    Retrieves SharePoint Online sites in the tenant.
.PARAMETER Url
    Optional site URL to retrieve
.EXAMPLE
    PS> ./Get-Site.ps1 -Url "https://contoso.sharepoint.com"
.CATEGORY O365
#>
[CmdletBinding()]
Param([string]$Url)
Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if (-not [System.String]::IsNullOrWhiteSpace($Url)) { $cmdArgs.Add('Identity', $Url) }
        $result = Get-SPOSite @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
