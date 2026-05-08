#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Lists members of a distribution group
.DESCRIPTION
    Retrieves mailboxes and nested groups from a distribution group with optional recursive expansion.
.PARAMETER GroupId
    Identity of the distribution group (alias, display name, DN, GUID, or email)
.PARAMETER Nested
    Recursively enumerate nested groups
.PARAMETER MemberObjectTypes
    Filter by member type: All, Users, or Groups
.EXAMPLE
    PS> ./Get-DistributionGroupMailbox.ps1 -GroupId "SalesTeam" -MemberObjectTypes Users
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,

    [switch]$Nested,

    [ValidateSet('All', 'Users', 'Groups')]
    [string]$MemberObjectTypes = 'All'
)

Process {
    try {
        $result = [System.Collections.ArrayList]::new()

        function Get-NestedMembers {
            param($group)

            $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; MemberType = "Group"; DisplayName = $group.DisplayName; PrimarySmtpAddress = $group.PrimarySmtpAddress })

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Users')) {
                $users = Get-DistributionGroupMember -Identity $group.Name -ErrorAction Stop | Where-Object { $_.RecipientType -EQ 'MailUser' } | Sort-Object -Property DisplayName
                foreach ($u in $users) {
                    $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; MemberType = "Mailbox"; DisplayName = $u.DisplayName; PrimarySmtpAddress = $u.PrimarySmtpAddress })
                }
            }

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Groups')) {
                $childGroups = Get-DistributionGroupMember -Identity $group.Name -ErrorAction Stop | Where-Object { $_.RecipientType -EQ 'MailUniversalDistributionGroup' } | Sort-Object -Property DisplayName
                foreach ($cg in $childGroups) {
                    if ($Nested) { Get-NestedMembers $cg }
                    else { $null = $result.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; MemberType = "Group"; DisplayName = $cg.DisplayName; PrimarySmtpAddress = $cg.PrimarySmtpAddress }) }
                }
            }
        }

        $grp = Get-DistributionGroup -Identity $GroupId -ErrorAction Stop
        if ($null -eq $grp) { throw "Distribution group not found" }

        Get-NestedMembers $grp

        if ($result.Count -gt 0) { Write-Output $result }
        else { Write-Output "No members found" }
    }
    catch { throw }
}
