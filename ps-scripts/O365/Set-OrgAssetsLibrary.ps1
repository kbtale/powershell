#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Configures org assets library
.DESCRIPTION
    Sets organization assets library configuration.
.PARAMETER LibraryUrl
    URL of the assets library
.EXAMPLE
    PS> ./Set-OrgAssetsLibrary.ps1 -LibraryUrl "https://contoso.sharepoint.com/sites/branding/Assets"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LibraryUrl
)

Process {
    try {
        $result = Set-SPOOrgAssetsLibrary -LibraryUrl $LibraryUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
