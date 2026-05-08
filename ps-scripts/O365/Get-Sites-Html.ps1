#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of sites
.DESCRIPTION
    Generates an HTML report of one or more site collections.
.PARAMETER Limit
    Maximum number of site collections to return
.PARAMETER Detailed
    Use this to get additional property information
.PARAMETER Properties
    List of properties to return; use * for all properties
.EXAMPLE
    PS> ./Get-Sites-Html.ps1 -Limit 100 -Detailed
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [switch]$Detailed,
    [int]$Limit = 200,
    [ValidateSet('*','Title','Status','Url','DisableFlows','AllowEditing','LastContentModifiedDate','CommentsOnSitePagesDisabled')]
    [string[]]$Properties = @('Title','Status','Url','DisableFlows','AllowEditing','LastContentModifiedDate','CommentsOnSitePagesDisabled')
)

Process {
    try {
        if ($Properties -contains '*') { $Properties = @('*') }
        $cmdArgs = @{ ErrorAction = 'Stop'; Detailed = $Detailed; Limit = $Limit }
        $result = Get-SPOSite @cmdArgs | Select-Object $Properties | Sort-Object Title
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}