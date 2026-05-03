#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Generates a detailed membership report for a Distribution Group

.DESCRIPTION
    Retrieves a comprehensive list of all members in a specified Distribution Group, with support for recursive expansion of nested groups.

.PARAMETER Identity
    Specifies the Identity of the distribution group.

.PARAMETER Recursive
    If set, recursively expands nested groups to show all effective members.

.EXAMPLE
    PS> ./Get-ExchangeDistributionGroupMemberReport.ps1 -Identity "Marketing" -Recursive

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [switch]$Recursive
)

Process {
    try {
        $group = Get-DistributionGroup -Identity $Identity -ErrorAction Stop
        
        function Get-ExchangeMembers {
            param($GroupId, $Depth = 0)
            $rawMembers = Get-DistributionGroupMember -Identity $GroupId -ErrorAction SilentlyContinue
            foreach ($member in $rawMembers) {
                $isGroup = $member.RecipientType -match 'Group'
                
                [PSCustomObject]@{
                    DisplayName       = $member.DisplayName
                    PrimarySmtpAddress = $member.PrimarySmtpAddress
                    RecipientType     = $member.RecipientType
                    Depth             = $Depth
                    ParentGroup       = $GroupId
                }

                if ($Recursive -and $isGroup) {
                    Get-ExchangeMembers -GroupId $member.DistinguishedName -Depth ($Depth + 1)
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
