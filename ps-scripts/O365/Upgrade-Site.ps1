#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Starts the upgrade process on a site collection
.DESCRIPTION
    Initiates a version upgrade on a SharePoint Online site collection.
.PARAMETER Identity
    URL of the site collection to upgrade
.PARAMETER NoEmail
    Do not send notification email upon completion
.PARAMETER QueueOnly
    Add to upgrade queue without immediate execution
.PARAMETER VersionUpgrade
    Perform a version-to-version upgrade
.EXAMPLE
    PS> ./Upgrade-Site.ps1 -Identity "https://contoso.sharepoint.com/sites/MySite" -VersionUpgrade
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,
    [switch]$NoEmail,
    [switch]$QueueOnly,
    [switch]$VersionUpgrade
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Identity; NoEmail = $NoEmail; QueueOnly = $QueueOnly; VersionUpgrade = $VersionUpgrade; Confirm = $false }
        $result = Upgrade-SPOSite @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}