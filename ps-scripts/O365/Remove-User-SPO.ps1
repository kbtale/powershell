#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes a user from a site collection
.DESCRIPTION
    Removes a user or security group from a site collection or a group.
.PARAMETER LoginName
    User name to remove
.PARAMETER Site
    URL of the site collection
.PARAMETER Group
    Group to remove the user from (optional)
.EXAMPLE
    PS> ./Remove-User.ps1 -LoginName "user@contoso.com" -Site "https://contoso.sharepoint.com/sites/MySite"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [string]$Group
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site; LoginName = $LoginName }
        if ($PSBoundParameters.ContainsKey('Group')) { $cmdArgs.Add('Group', $Group) }
        $result = Remove-SPOUser @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}