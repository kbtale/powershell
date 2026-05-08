#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Remove members from Azure AD roles
.DESCRIPTION
    Removes users or service principals from Azure AD roles.
.PARAMETER RoleIds
    Unique IDs of the roles
.PARAMETER RoleNames
    Names of the roles
.PARAMETER UserIds
    Unique IDs of the users to remove
.PARAMETER UserNames
    Display names or UPNs of users to remove
.PARAMETER ServicePrincipalIds
    Unique IDs of service principals to remove
.PARAMETER ServicePrincipalNames
    Display names of service principals to remove
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Remove-MsOUsersFromRoles.ps1 -RoleNames @("Helpdesk Administrator") -UserNames @("admin@domain.com")
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Ids')]
    [guid[]]$RoleIds,
    [Parameter(Mandatory = $true, ParameterSetName = 'Names')]
    [string[]]$RoleNames,
    [Parameter(ParameterSetName = 'Ids')]
    [Parameter(ParameterSetName = 'Names')]
    [guid[]]$UserIds,
    [Parameter(ParameterSetName = 'Ids')]
    [Parameter(ParameterSetName = 'Names')]
    [string[]]$UserNames,
    [Parameter(ParameterSetName = 'Ids')]
    [Parameter(ParameterSetName = 'Names')]
    [guid[]]$ServicePrincipalIds,
    [Parameter(ParameterSetName = 'Ids')]
    [Parameter(ParameterSetName = 'Names')]
    [string[]]$ServicePrincipalNames,
    [guid]$TenantId
)

Process {
    try {
        $roles = @()
        if ($PSCmdlet.ParameterSetName -eq 'Ids') { foreach ($id in $RoleIds) { $roles += Get-MsolRole -ObjectId $id -TenantId $TenantId -ErrorAction Stop } }
        else { $allRoles = Get-MsolRole -TenantId $TenantId -ErrorAction Stop; foreach ($n in $RoleNames) { $roles += $allRoles | Where-Object Name -eq $n } }

        $members = @()
        if ($UserIds) { foreach ($id in $UserIds) { $members += Get-MsolUser -ObjectId $id -TenantId $TenantId -ErrorAction Stop } }
        if ($UserNames) { foreach ($n in $UserNames) { $members += Get-MsolUser -SearchString $n -TenantId $TenantId -ErrorAction Stop } }
        if ($ServicePrincipalIds) { foreach ($id in $ServicePrincipalIds) { $members += Get-MsolServicePrincipal -ObjectId $id -TenantId $TenantId -ErrorAction Stop } }
        if ($ServicePrincipalNames) { foreach ($n in $ServicePrincipalNames) { $members += Get-MsolServicePrincipal -SearchString $n -TenantId $TenantId -ErrorAction Stop } }

        $result = @()
        foreach ($role in $roles) {
            foreach ($mem in $members) {
                try { Remove-MsolRoleMember -RoleObjectId $role.ObjectId -RoleMemberObjectId $mem.ObjectId -RoleMemberType $mem.ObjectType -TenantId $TenantId -ErrorAction Stop; $result += "Removed $($mem.DisplayName) from role $($role.Name)" }
                catch { $result += "Error removing from role $($role.Name)" }
            }
        }
        foreach ($msg in $result) { [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; Result = $msg } }
    }
    catch { throw }
}
