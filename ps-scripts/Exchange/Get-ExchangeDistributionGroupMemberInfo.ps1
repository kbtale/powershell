#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Retrieves members of a Distribution Group

.DESCRIPTION
    Lists all members of a specified Microsoft Exchange Distribution Group. Supports recursive (nested) membership expansion and filtering by recipient type.

.PARAMETER Identity
    Specifies the Identity of the distribution group.

.PARAMETER Recursive
    If set, recursively expands nested groups to show all effective members.

.PARAMETER MemberType
    Optional filter for the type of members to return (e.g., Mailbox, Group, Contact).

.EXAMPLE
    PS> ./Get-ExchangeDistributionGroupMemberInfo.ps1 -Identity "Global Staff" -Recursive

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [switch]$Recursive,

    [ValidateSet('All', 'Mailbox', 'Group', 'Contact')]
    [string]$MemberType = 'All'
)

Process {
    try {
        $group = Get-DistributionGroup -Identity $Identity -ErrorAction Stop
        
        function Get-ExchangeMembers {
            param($GroupId)
            $rawMembers = Get-DistributionGroupMember -Identity $GroupId -ErrorAction SilentlyContinue
            foreach ($member in $rawMembers) {
                $isGroup = $member.RecipientType -match 'Group'
                
                $match = $false
                if ($MemberType -eq 'All') { $match = $true }
                elseif ($MemberType -eq 'Mailbox' -and $member.RecipientType -match 'Mailbox') { $match = $true }
                elseif ($MemberType -eq 'Group' -and $isGroup) { $match = $true }
                elseif ($MemberType -eq 'Contact' -and $member.RecipientType -match 'Contact') { $match = $true }

                if ($match) {
                    [PSCustomObject]@{
                        DisplayName    = $member.DisplayName
                        PrimarySmtpAddress = $member.PrimarySmtpAddress
                        RecipientType  = $member.RecipientType
                        ParentGroup    = $GroupId
                    }
                }

                if ($Recursive -and $isGroup) {
                    Get-ExchangeMembers -GroupId $member.DistinguishedName
                }
            }
        }

        $results = Get-ExchangeMembers -GroupId $group.DistinguishedName
        Write-Output ($results | Sort-Object DisplayName -Unique)
    }
    catch {
        throw
    }
}
