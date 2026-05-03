#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Adds members to a Distribution Group

.DESCRIPTION
    Adds one or more members (Mailboxes, Mail Users, or other Groups) to a specified Microsoft Exchange Distribution Group.

.PARAMETER Identity
    Specifies the Identity of the distribution group.

.PARAMETER Member
    Specifies one or more identities of the members to add.

.PARAMETER BypassManagerCheck
    If set, bypasses the security group manager check.

.EXAMPLE
    PS> ./Add-ExchangeDistributionGroupMember.ps1 -Identity "Marketing" -Member "user1@contoso.com", "user2@contoso.com"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string[]]$Member,

    [switch]$BypassManagerCheck
)

Process {
    try {
        $results = foreach ($m in $Member) {
            try {
                $params = @{
                    'Identity'    = $Identity
                    'Member'      = $m
                    'Confirm'     = $false
                    'ErrorAction' = 'Stop'
                }
                if ($BypassManagerCheck.IsPresent) { $params.Add('BypassSecurityGroupManagerCheck', $true) }

                Add-DistributionGroupMember @params

                [PSCustomObject]@{
                    Group     = $Identity
                    Member    = $m
                    Action    = "MemberAdded"
                    Status    = "Success"
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
            catch {
                [PSCustomObject]@{
                    Group     = $Identity
                    Member    = $m
                    Action    = "MemberAdded"
                    Status    = "Failed"
                    Error     = $_.Exception.Message
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
        }

        Write-Output $results
    }
    catch {
        throw
    }
}
