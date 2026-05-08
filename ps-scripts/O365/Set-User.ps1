#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Configures properties on an existing user
.DESCRIPTION
    Modifies properties of an existing SharePoint Online user.
.PARAMETER LoginName
    User login name
.PARAMETER Site
    Full URL of the site collection
.PARAMETER IsSiteCollectionAdmin
    Set whether the user is a site collection administrator
.EXAMPLE
    PS> ./Set-User.ps1 -LoginName "user@contoso.com" -Site "https://contoso.sharepoint.com/sites/MySite" -IsSiteCollectionAdmin $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [bool]$IsSiteCollectionAdmin
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; LoginName = $LoginName; Site = $Site }
        if ($PSBoundParameters.ContainsKey('IsSiteCollectionAdmin')) { $cmdArgs.Add('IsSiteCollectionAdmin', $IsSiteCollectionAdmin) }
        $result = Set-SPOUser @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}