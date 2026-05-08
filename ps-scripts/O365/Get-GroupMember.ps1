#Requires -Version 5.1
#Requires -Modules AzureAD

<#
.SYNOPSIS
    Azure AD: Retrieves group members

.DESCRIPTION
    Retrieves members (users and/or groups) from a specified Azure Active Directory group with optional nested expansion.

.PARAMETER GroupObjectId
    Unique ID of the group from which to get members

.PARAMETER GroupName
    Display name of the group from which to get members

.PARAMETER Nested
    Shows group members nested

.PARAMETER MemberObjectTypes
    Specifies the member object types to return: All, Users, or Groups

.EXAMPLE
    PS> ./Get-GroupMember.ps1 -GroupName "Sales Team" -MemberObjectTypes Users

.CATEGORY O365
#>

[CmdletBinding(DefaultParameterSetName = "Group name")]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Group object id")]
    [guid]$GroupObjectId,

    [Parameter(Mandatory = $true, ParameterSetName = "Group name")]
    [string]$GroupName,

    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [switch]$Nested,

    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [ValidateSet('All', 'Users', 'Groups')]
    [string]$MemberObjectTypes = 'All'
)

Process {
    try {
        $result = @()

        function Get-NestedGroupMember {
            param($group)

            $result += [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                MemberType   = "Group"
                DisplayName  = $group.DisplayName
                ObjectId     = $group.ObjectId
            }

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Users')) {
                $users = Get-AzureADGroupMember -ObjectId $group.ObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'User' } | Sort-Object -Property DisplayName
                foreach ($u in $users) {
                    $result += [PSCustomObject]@{
                        Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                        MemberType   = "User"
                        DisplayName  = $u.DisplayName
                        ObjectId     = $u.ObjectId
                    }
                }
            }
            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Groups')) {
                $childGroups = Get-AzureADGroupMember -ObjectId $group.ObjectId -ErrorAction Stop | Where-Object { $_.ObjectType -eq 'Group' } | Sort-Object -Property DisplayName
                foreach ($cg in $childGroups) {
                    if ($Nested -eq $true) {
                        Get-NestedGroupMember $cg
                    }
                    else {
                        $result += [PSCustomObject]@{
                            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                            MemberType   = "Group"
                            DisplayName  = $cg.DisplayName
                            ObjectId     = $cg.ObjectId
                        }
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq "Group object id") {
            $grp = Get-AzureADGroup -ObjectId $GroupObjectId -ErrorAction Stop
        }
        else {
            $grp = Get-AzureADGroup -All $true -ErrorAction Stop | Where-Object { $_.Displayname -eq $GroupName }
        }

        if ($null -ne $grp) {
            Get-NestedGroupMember $grp
        }
        else {
            throw "Group not found"
        }

        if ($result.Count -gt 0) {
            Write-Output $result
        }
        else {
            Write-Output "No members found"
        }
    }
    catch {
        throw
    }
}
