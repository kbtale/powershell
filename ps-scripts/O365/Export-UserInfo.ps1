#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Exports user info
.DESCRIPTION
    Exports user information from the site user information list.
.PARAMETER LoginName
    Login name of the user to export
.PARAMETER OutputFolder
    Target folder where the CSV file is generated
.PARAMETER Site
    URL of the site collection
.EXAMPLE
    PS> ./Export-UserInfo.ps1 -LoginName "user@contoso.com" -OutputFolder "C:\Exports" -Site "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder,
    [Parameter(Mandatory = $true)]
    [string]$Site
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; LoginName = $LoginName; OutputFolder = $OutputFolder; Site = $Site }
        Export-SPOUserInfo @cmdArgs | Out-Null
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User info exported for '$LoginName' to '$OutputFolder'" }
    }
    catch { throw }
}