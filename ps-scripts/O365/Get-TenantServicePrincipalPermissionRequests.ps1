#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets service principal permission requests
.DESCRIPTION
    Returns the collection of permission requests for the SharePoint Online Client service principal.
.EXAMPLE
    PS> ./Get-TenantServicePrincipalPermissionRequests.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOTenantServicePrincipalPermissionRequests -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}