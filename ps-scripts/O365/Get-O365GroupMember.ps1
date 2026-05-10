#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves members of a group
.DESCRIPTION
    Gets members (users and/or groups) of a group with optional recursive nested expansion.
.PARAMETER GroupObjectId
    Unique object ID of the group
.PARAMETER GroupName
    Display name of the group
.PARAMETER Nested
    Recursively enumerate nested group members
.PARAMETER MemberObjectTypes
    Filter by member type: All, Users, or Groups
.EXAMPLE
    PS> ./Get-GroupMember.ps1 -GroupName "Sales Team" -MemberObjectTypes Users
.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "GroupName")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "GroupObjectId")]
    [guid]$GroupObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "GroupName")]
    [string]$GroupName,

    [Parameter(ParameterSetName = "GroupName")]
    [Parameter(ParameterSetName = "GroupObjectId")]
    [switch]$Nested,

    [Parameter(ParameterSetName = "GroupName")]
    [Parameter(ParameterSetName = "GroupObjectId")]
    [ValidateSet('All', 'Users', 'Groups')]
    [string]$MemberObjectTypes = 'All'
)

Process {
    try {
        $result = [System.Collections.ArrayList]::new()

        function Get-NestedMembers {
            param($group)

            $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; ObjectType = "Group"; DisplayName = $group.DisplayName; ObjectId = $group.ObjectId })

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Users')) {
                $users = Get-AzureADGroupMember -ObjectId $group.ObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'User' } | Sort-Object -Property DisplayName
                foreach ($u in $users) {
                    $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; ObjectType = "User"; DisplayName = $u.DisplayName; ObjectId = $u.ObjectId })
                }
            }

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Groups')) {
                $childGroups = Get-AzureADGroupMember -ObjectId $group.ObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'Group' } | Sort-Object -Property DisplayName
                foreach ($cg in $childGroups) {
                    if ($Nested) { Get-NestedMembers $cg }
                    else {
                        $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; ObjectType = "Group"; DisplayName = $cg.DisplayName; ObjectId = $cg.ObjectId })
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "GroupObjectId") {
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName }
        }

        if ($null -eq $grp) { throw "Group not found" }

        Get-NestedMembers $grp

        if ($result.Count -gt 0) { Write-Output $result }
        else { Write-Output "No members found" }
    }
    catch { throw }
}
