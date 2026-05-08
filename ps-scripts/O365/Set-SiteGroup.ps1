#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Updates a site group
.DESCRIPTION
    Modifies the owner and permission levels on a group inside a site collection.
.PARAMETER Site
    URL of the site collection the group belongs to
.PARAMETER Group
    Name of the group to update
.PARAMETER Name
    New name for the group
.PARAMETER Owner
    New owner for the group
.PARAMETER PermissionLevelsToAdd
    Permission level to add to the group
.PARAMETER PermissionLevelsToRemove
    Permission level to remove from the group
.EXAMPLE
    PS> ./Set-SiteGroup.ps1 -Site "https://contoso.sharepoint.com/sites/MySite" -Group "Team Members" -Name "New Team Members"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [string]$Group,
    [string]$Name,
    [string]$Owner,
    [ValidateSet('View Only','Read','Limited Access','Contribute','Approve','Edit','Design','Manage Hierarchy','Full Control')]
    [string]$PermissionLevelsToAdd,
    [ValidateSet('View Only','Read','Limited Access','Contribute','Approve','Edit','Design','Manage Hierarchy','Full Control')]
    [string]$PermissionLevelsToRemove
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site; Identity = $Group }
        if (-not [System.String]::IsNullOrWhiteSpace($Name)) { $cmdArgs.Add('Name', $Name) }
        if (-not [System.String]::IsNullOrWhiteSpace($Owner)) { $cmdArgs.Add('Owner', $Owner) }
        if (-not [System.String]::IsNullOrWhiteSpace($PermissionLevelsToAdd)) { $cmdArgs.Add('PermissionLevelsToAdd', $PermissionLevelsToAdd) }
        if (-not [System.String]::IsNullOrWhiteSpace($PermissionLevelsToRemove)) { $cmdArgs.Add('PermissionLevelsToRemove', $PermissionLevelsToRemove) }
        $result = Set-SPOSiteGroup @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}