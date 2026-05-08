#Requires -Version 5.1
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
.SYNOPSIS
    SharePoint Online: Revokes a service principal permission
.DESCRIPTION
    Revokes a previously granted permission for the SharePoint Online Client service principal.
.PARAMETER ObjectId
    Object ID of the permission grant to revoke
.EXAMPLE
    PS> ./Revoke-TenantServicePrincipalPermission.ps1 -ObjectId "a1b2c3d4-1234-5678-90ab-cdef12345678"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ObjectId
)

Process {
    try {
        $result = Revoke-SPOTenantServicePrincipalPermission -ObjectID $ObjectId -Confirm:$false -ErrorAction Stop | Select-Object *
        if ($null -ne $result) { foreach ($item in $result) { $item | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force } }
    }
    catch { throw }
}