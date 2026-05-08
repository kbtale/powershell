#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell
<#
.SYNOPSIS
    SharePoint Online: Gets site designs
.DESCRIPTION
    Retrieves site designs from the tenant.
.PARAMETER Identity
    Optional site design ID
.EXAMPLE
    PS> ./Get-SiteDesign.ps1
.CATEGORY O365
#>
[CmdletBinding()]
Param([guid]$Identity)
Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop' }
        if ($PSBoundParameters.ContainsKey('Identity')) { $cmdArgs.Add('Identity', $Identity) }
        $result = Get-SPOSiteDesign @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($i in $result) { $i | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}
