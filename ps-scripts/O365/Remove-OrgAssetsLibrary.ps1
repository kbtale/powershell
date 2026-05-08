#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes an org assets library
.DESCRIPTION
    Deletes an organization assets library designation.
.PARAMETER LibraryUrl
    URL of the library to remove
.EXAMPLE
    PS> ./Remove-OrgAssetsLibrary.ps1 -LibraryUrl "https://contoso.sharepoint.com/sites/branding/Assets"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LibraryUrl
)

Process {
    try {
        Remove-SPOOrgAssetsLibrary -LibraryUrl $LibraryUrl -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Org assets library '$LibraryUrl' removed" }
    }
    catch { throw }
}
