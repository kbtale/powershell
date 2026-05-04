#Requires -Version 5.1
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
    MgmtGraph: Searches for Microsoft Graph API permissions and scopes

.DESCRIPTION
    Searches for available permissions within the Microsoft Graph API, filtering by type (Delegated, Application) or searching online for the latest documentation.

.PARAMETER Online
    If set, searches for permissions online to ensure the latest information is retrieved.

.PARAMETER PermissionType
    Optional. Filters permissions by type (Delegated, Application, or Any).

.EXAMPLE
    PS> ./Find-MgmtGraphPermission.ps1 -PermissionType Application

.CATEGORY Microsoft Graph
#>

[CmdletBinding()]
Param (
    [switch]$Online,

    [ValidateSet('Any', 'Application', 'Delegated')]
    [string]$PermissionType = "Any"
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }

        if ($Online) { $params.Add('Online', $true) }
        if ($PermissionType -ne "Any") { $params.Add('PermissionType', $PermissionType) }

        $permissions = Find-MgGraphPermission @params
        
        $results = foreach ($perm in $permissions) {
            [PSCustomObject]@{
                Name        = $perm.Name
                Description = $perm.Description
                IsAdmin     = $perm.IsAdmin
                PermissionType = $perm.PermissionType
                Timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
