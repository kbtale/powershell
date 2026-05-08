#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of external users
.DESCRIPTION
    Generates an HTML report of external users in the tenant.
.PARAMETER Filter
    Limits results to users whose name or email begins with the specified text
.PARAMETER PageSize
    Maximum number of users to return
.PARAMETER SiteUrl
    Site to retrieve external users for
.PARAMETER SortOrder
    Sort order: Ascending or Descending
.EXAMPLE
    PS> ./Get-ExternalUser-Html.ps1 -PageSize 20
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [string]$Filter,
    [ValidateRange(1, 50)]
    [int]$PageSize,
    [int]$Position,
    [bool]$ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount,
    [string]$SiteUrl,
    [ValidateSet('Ascending','Descending')]
    [string]$SortOrder
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount = $ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount }
        if ($PSBoundParameters.ContainsKey('Filter')) { $cmdArgs.Add('Filter', $Filter) }
        if ($PSBoundParameters.ContainsKey('PageSize')) { $cmdArgs.Add('PageSize', $PageSize) }
        if ($PSBoundParameters.ContainsKey('Position')) { $cmdArgs.Add('Position', $Position) }
        if ($PSBoundParameters.ContainsKey('SiteUrl')) { $cmdArgs.Add('SiteUrl', $SiteUrl) }
        if ($PSBoundParameters.ContainsKey('SortOrder')) { $cmdArgs.Add('SortOrder', $SortOrder) }
        $result = Get-SPOExternalUser @cmdArgs | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}