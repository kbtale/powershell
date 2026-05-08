#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: HTML report of group members
.DESCRIPTION
    Generates an HTML report of group members with optional recursive nested expansion.
.PARAMETER GroupObjectId
    Unique object ID of the group
.PARAMETER GroupName
    Display name of the group
.PARAMETER Nested
    Recursively enumerate nested groups
.PARAMETER MemberObjectTypes
    Filter by member type: All, Users, or Groups
.EXAMPLE
    PS> ./Get-GroupMember-Html.ps1 -GroupName "Sales Team" | Out-File report.html
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
        $members = [System.Collections.ArrayList]::new()

        function Get-NestedMembers {
            param($group)

            $null = $members.Add([PSCustomObject]@{ Type = 'Group'; DisplayName = $group.DisplayName })

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Users')) {
                $users = Get-AzureADGroupMember -ObjectId $group.ObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'User' } | Sort-Object -Property DisplayName
                foreach ($u in $users) { $null = $members.Add([PSCustomObject]@{ Type = 'User'; DisplayName = $u.DisplayName }) }
            }

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Groups')) {
                $childGroups = Get-AzureADGroupMember -ObjectId $group.ObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'Group' } | Sort-Object -Property DisplayName
                foreach ($cg in $childGroups) {
                    if ($Nested) { Get-NestedMembers $cg }
                    else { $null = $members.Add([PSCustomObject]@{ Type = 'Group'; DisplayName = $cg.DisplayName }) }
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

        if ($members.Count -gt 0) {
            Write-Output ($members | ConvertTo-Html -Fragment)
        }
        else { Write-Output "No members found" }
    }
    catch { throw }
}
