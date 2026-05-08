#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Sets hide default themes
.DESCRIPTION
    Configures whether default themes are hidden from users.
.PARAMETER HideDefaultThemes
    Set to hide or show default themes
.EXAMPLE
    PS> ./Set-HideDefaultThemes.ps1 -HideDefaultThemes $true
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [bool]$HideDefaultThemes
)

Process {
    try {
        Set-SPOHideDefaultThemes -HideDefaultThemes $HideDefaultThemes -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; HideDefaultThemes = $HideDefaultThemes.ToString() }
    }
    catch { throw }
}
