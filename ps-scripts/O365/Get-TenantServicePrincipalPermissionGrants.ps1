#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Gets service principal permission grants
.DESCRIPTION
    Returns the collection of permission grants for the SharePoint Online Client service principal.
.EXAMPLE
    PS> ./Get-TenantServicePrincipalPermissionGrants.ps1
.CATEGORY O365
#>

Process {
    try {
        $result = Get-SPOTenantServicePrincipalPermissionGrants -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}