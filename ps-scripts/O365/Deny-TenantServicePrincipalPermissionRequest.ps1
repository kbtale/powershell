#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Denies a service principal permission request
.DESCRIPTION
    Denies a permission request for the tenant's SharePoint Online Client service principal.
.PARAMETER RequestId
    The ID of the permission request to deny
.EXAMPLE
    PS> ./Deny-TenantServicePrincipalPermissionRequest.ps1 -RequestId "a1b2c3d4-1234-5678-90ab-cdef12345678"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$RequestId
)

Process {
    try {
        $cmdArgs = @{ ErrorAction = 'Stop'; RequestId = $RequestId }
        $result = Deny-SPOTenantServicePrincipalPermissionRequest @cmdArgs | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}