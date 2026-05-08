#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Revokes rights for specified principals to a hub
.DESCRIPTION
    Removes permissions from specified principals on a hub site.
.PARAMETER Site
    URL of the hub site
.PARAMETER Principals
    Comma-separated list of principals to revoke permissions from
.EXAMPLE
    PS> ./Revoke-HubSiteRights.ps1 -Site "https://contoso.sharepoint.com/sites/Hub" -Principals "user1@contoso.com,user2@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [string]$Principals
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Site }
        if (-not [System.String]::IsNullOrWhiteSpace($Principals)) { $cmdArgs.Add('Principals', $Principals.Split(',')) }
        $result = Revoke-SPOHubSiteRights @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}