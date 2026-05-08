#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Removes an org news site
.DESCRIPTION
    Removes the organization news site designation.
.EXAMPLE
    PS> ./Remove-OrgNewsSite.ps1
.CATEGORY O365
#>

Process {
    try {
        Remove-SPOOrgNewsSite -ErrorAction Stop
        [PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Org news site removed" }
    }
    catch { throw }
}
