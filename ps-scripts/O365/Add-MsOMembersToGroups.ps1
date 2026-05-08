#Requires -Version 5.1

<#
.SYNOPSIS
    MSOnline: Adds members to Azure AD groups
.DESCRIPTION
    Adds users or groups as members to Azure Active Directory groups using the MSOnline module.
.PARAMETER TargetGroupNames
    Display names of the target groups
.PARAMETER GroupNames
    Display names of the groups to add as members
.PARAMETER UserNames
    Sign-In names, display names or UPNs of the users to add
.PARAMETER GroupObjectIds
    Unique IDs of the target groups
.PARAMETER GroupIds
    Unique object IDs of the groups to add
.PARAMETER UserIds
    Unique object IDs of the users to add
.PARAMETER TenantId
    Unique ID of the tenant
.EXAMPLE
    PS> ./Add-MsOMembersToGroups.ps1 -TargetGroupNames @("Sales Team") -UserNames @("user@domain.com")
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Names')]
    [string[]]$TargetGroupNames,
    [Parameter(ParameterSetName = 'Names')]
    [string[]]$GroupNames,
    [Parameter(ParameterSetName = 'Names')]
    [string[]]$UserNames,
    [Parameter(Mandatory = $true, ParameterSetName = 'Ids')]
    [string[]]$GroupObjectIds,
    [Parameter(ParameterSetName = 'Ids')]
    [string[]]$GroupIds,
    [Parameter(ParameterSetName = 'Ids')]
    [string[]]$UserIds,
    [Parameter(ParameterSetName = 'Names')]
    [Parameter(ParameterSetName = 'Ids')]
    [guid]$TenantId
)

Process {
    try {
        $targetGroups = @()
        if ($PSCmdlet.ParameterSetName -eq 'Names') {
            foreach ($name in $TargetGroupNames) { $targetGroups += Get-MsolGroup -SearchString $name -TenantId $TenantId -ErrorAction Stop }
        }
        else {
            foreach ($id in $GroupObjectIds) { $targetGroups += Get-MsolGroup -ObjectId $id -TenantId $TenantId -ErrorAction Stop }
        }

        $members = @()
        if ($GroupNames) { foreach ($n in $GroupNames) { $members += Get-MsolGroup -SearchString $n -TenantId $TenantId -ErrorAction Stop } }
        if ($GroupIds) { foreach ($id in $GroupIds) { $members += Get-MsolGroup -ObjectId $id -TenantId $TenantId -ErrorAction Stop } }
        if ($UserNames) { foreach ($n in $UserNames) { $members += Get-MsolUser -SearchString $n -TenantId $TenantId -ErrorAction Stop } }
        if ($UserIds) { foreach ($id in $UserIds) { $members += Get-MsolUser -ObjectId $id -TenantId $TenantId -ErrorAction Stop } }

        $result = @()
        foreach ($grp in $targetGroups) {
            foreach ($mem in $members) {
                try {
                    Add-MsolGroupMember -GroupObjectId $grp.ObjectId -GroupMemberObjectId $mem.ObjectId -GroupMemberType $mem.ObjectType -TenantId $TenantId -ErrorAction Stop
                    $result += "Member $($mem.DisplayName) added to group $($grp.DisplayName)"
                }
                catch { $result += "Error adding member $($mem.DisplayName) to group $($grp.DisplayName)" }
            }
        }
        foreach ($msg in $result) { [PSCustomObject]@{ Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; Result = $msg } }
    }
    catch { throw }
}
