#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Disables the hub site feature on a site
.DESCRIPTION
    Removes the hub site designation from a site, reverting it to a regular site.
.PARAMETER Site
    URL or GUID identifier of the site to unregister as a hub
.EXAMPLE
    PS> ./Unregister-HubSite.ps1 -Site "https://contoso.sharepoint.com/sites/Hub"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site
)

Process {
    try {
        $result = Unregister-SPOHubSite -Confirm:$false -Identity $Site -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}