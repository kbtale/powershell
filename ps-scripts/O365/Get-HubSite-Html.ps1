#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of hub sites
.DESCRIPTION
    Generates an HTML report of registered hub sites in the tenant.
.EXAMPLE
    PS> ./Get-HubSite-Html.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOHubSite -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}