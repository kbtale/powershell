#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Revokes rights from a site design
.DESCRIPTION
    Removes permissions from specified principals on a site design.
.PARAMETER Site
    ID of the site design from which to revoke rights
.PARAMETER Principals
    Comma-separated list of principals to revoke rights from
.EXAMPLE
    PS> ./Revoke-SiteDesignRights.ps1 -Site "db752673-18fd-44db-865a-aa3e0b28698e" -Principals "user1@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [string]$Principals
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Identity = $Site; Principals = $Principals.Split(',') }
        $result = Revoke-SPOSiteDesignRights @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}