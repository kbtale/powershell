#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Adds members to distribution groups
.DESCRIPTION
    Adds mailboxes and/or distribution groups as members to one or more Universal distribution groups.
.PARAMETER GroupObjectIds
    Identities of the target distribution groups (alias, display name, DN, GUID, or email)
.PARAMETER GroupIds
    Identities of distribution groups to add as members
.PARAMETER UserIds
    Identities of mail users to add as members
.EXAMPLE
    PS> ./Add-MemberToDistributionGroup.ps1 -GroupObjectIds "SalesTeam" -UserIds "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string[]]$GroupObjectIds,

    [string[]]$GroupIds,
    [string[]]$UserIds
)

Process {
    try {
        $results = [System.Collections.ArrayList]::new()

        foreach ($gid in $GroupObjectIds) {
            try { $grp = Get-DistributionGroup -Identity $gid -ErrorAction Stop }
            catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$gid' not found: $($_.Exception.Message)" }); continue }

            if ($null -ne $GroupIds) {
                foreach ($mid in $GroupIds) {
                    try { $memberGrp = Get-DistributionGroup -Identity $mid -ErrorAction Stop }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Member group '$mid' not found: $($_.Exception.Message)" }); continue }

                    try {
                        $null = Add-DistributionGroupMember -Identity $gid -Member $mid -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                        $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Group '$($memberGrp.DisplayName)' added to '$($grp.DisplayName)'" })
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$mid': $($_.Exception.Message)" }) }
                }
            }

            if ($null -ne $UserIds) {
                foreach ($uid in $UserIds) {
                    try { $usr = Get-MailUser -Identity $uid -ErrorAction Stop }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$uid' not found: $($_.Exception.Message)" }); continue }

                    try {
                        $null = Add-DistributionGroupMember -Identity $gid -Member $uid -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                        $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User '$($usr.DisplayName)' added to '$($grp.DisplayName)'" })
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$uid': $($_.Exception.Message)" }) }
                }
            }
        }

        Write-Output $results
    }
    catch { throw }
}
