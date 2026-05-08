#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Adds a user or security group to a SharePoint group
.DESCRIPTION
    Adds an existing Office 365 user or security group to a SharePoint Online group.
.PARAMETER Site
    URL of the site collection
.PARAMETER LoginName
    User name to add
.PARAMETER Group
    Group to add the user to
.PARAMETER Limit
    Maximum number of users to return (for All/ByGroup queries)
.EXAMPLE
    PS> ./Add-User.ps1 -Site "https://contoso.sharepoint.com/sites/MySite" -LoginName "user@contoso.com" -Group "Team Members"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(ParameterSetName = 'ByLoginName', Mandatory = $true)]
    [string]$LoginName,
    [Parameter(ParameterSetName = 'ByGroup', Mandatory = $true)]
    [string]$Group,
    [Parameter(ParameterSetName = 'All')]
    [Parameter(ParameterSetName = 'ByGroup')]
    [int]$Limit = 500
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; Site = $Site }
        if ($PSCmdlet.ParameterSetName -eq 'All') { $cmdArgs.Add('Limit', $Limit) }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByGroup') { $cmdArgs.Add('Limit', $Limit); $cmdArgs.Add('Group', $Group) }
        elseif ($PSCmdlet.ParameterSetName -eq 'ByLoginName') { $cmdArgs.Add('LoginName', $LoginName) }
        $result = Get-SPOUser @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}