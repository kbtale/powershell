#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets users from a site collection
.DESCRIPTION
    Returns SharePoint Online user or security group accounts matching a given search criteria.
.PARAMETER Site
    URL of the site collection
.PARAMETER LoginName
    Specific user login name to retrieve
.PARAMETER Group
    Filter users by group membership
.PARAMETER Limit
    Maximum number of users to return
.EXAMPLE
    PS> ./Get-User.ps1 -Site "https://contoso.sharepoint.com/sites/MySite" -Group "Team Members"
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