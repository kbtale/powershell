#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Adds an organization assets library
.DESCRIPTION
    Adds an organization assets library from a given URL.
.PARAMETER LibraryUrl
    URL of the library to add as an organization asset
.EXAMPLE
    PS> ./Add-OrgAssetsLibrary.ps1 -LibraryUrl "https://contoso.sharepoint.com/sites/branding/Assets"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LibraryUrl
)

Process {
    try {
        $result = Add-SPOOrgAssetsLibrary -LibraryUrl $LibraryUrl -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { $result | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force }
    }
    catch { throw }
}
