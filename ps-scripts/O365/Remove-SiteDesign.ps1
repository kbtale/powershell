#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a site design
.DESCRIPTION
    Deletes a previously uploaded site design by its identity.
.PARAMETER Identity
    ID of the site design to remove
.EXAMPLE
    PS> ./Remove-SiteDesign.ps1 -Identity "db752673-18fd-44db-865a-aa3e0b28698e"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity }
        Remove-SPOSiteDesign @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Site design '$Identity' removed" }
    }
    catch { throw }
}