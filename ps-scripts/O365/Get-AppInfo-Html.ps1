#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: HTML report of app info
.DESCRIPTION
    Generates an HTML report of SharePoint Online app information.
.EXAMPLE
    PS> ./Get-AppInfo-Html.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOAppInfo -ErrorAction Stop | Select-Object *
        Write-Output ($result | ConvertTo-Html -Fragment)
    }
    catch { throw }
}