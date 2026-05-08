#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: HTML report of distribution group mailboxes
.DESCRIPTION
    Generates an HTML report of mailboxes that are members of a specified universal distribution group, with optional nested group expansion.
.PARAMETER GroupId
    Alias, Display name, Distinguished name, Guid or Mail address of the universal distribution group
.PARAMETER Nested
    Shows group members recursively
.PARAMETER MemberObjectTypes
    Member object types to include: All, Users, or Groups
.EXAMPLE
    PS> ./Get-DistributionGroupMailbox-Html.ps1 -GroupId "SalesGroup" | Out-File report.html
.EXAMPLE
    PS> ./Get-DistributionGroupMailbox-Html.ps1 -GroupId "SalesGroup" -Nested
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
        $Members = New-Object System.Collections.Generic.List[PSCustomObject]

        function Get-NestedGroupMember {
            param($group)
            $Members.Add([PSCustomObject]@{Type = 'Group'; DisplayName = $group.DisplayName; 'Smtp address' = $group.PrimarySmtpAddress})

            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Users')) {
                Get-DistributionGroupMember -Identity $group.Name -ErrorAction Stop | Where-Object { $_.RecipientType -EQ 'MailUser' } | Sort-Object -Property DisplayName | ForEach-Object {
                    $Members.Add([PSCustomObject]@{Type = 'Mailbox'; DisplayName = $_.DisplayName; 'Smtp address' = $_.PrimarySmtpAddress})
                }
            }
            if (($MemberObjectTypes -eq 'All') -or ($MemberObjectTypes -eq 'Groups')) {
                Get-DistributionGroupMember -Identity $group.Name -ErrorAction Stop | Where-Object { $_.RecipientType -EQ 'MailUniversalDistributionGroup' } | Sort-Object -Property DisplayName | ForEach-Object {
                    if ($Nested) {
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Members.Add([PSCustomObject]@{Type = 'Group'; DisplayName = $_.DisplayName; 'Smtp address' = $_.PrimarySmtpAddress})
                    }
                }
            }
        }

        $Grp = Get-DistributionGroup -Identity $GroupId -ErrorAction Stop
        if ($null -eq $Grp) {
            throw "Universal distribution group not found"
        }
        Get-NestedGroupMember $Grp

        if ($null -eq $Members -or $Members.Count -eq 0) {
            Write-Output "No Universal distribution group members found"
            return
        }

        Write-Output ($Members.ToArray() | ConvertTo-Html -Fragment)
    }
    catch { throw }
}
