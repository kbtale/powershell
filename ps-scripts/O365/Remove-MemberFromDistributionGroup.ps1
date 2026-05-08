#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Removes members from distribution groups
.DESCRIPTION
    Removes mailboxes and/or distribution groups from one or more Universal distribution groups.
.PARAMETER GroupObjectIds
    Identities of the target distribution groups
.PARAMETER GroupIds
    Identities of distribution groups to remove
.PARAMETER UserIds
    Identities of mail users to remove
.EXAMPLE
    PS> ./Remove-MemberFromDistributionGroup.ps1 -GroupObjectIds "SalesTeam" -UserIds "john.doe@contoso.com"
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
                        $null = Remove-DistributionGroupMember -Identity $gid -Member $mid -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                        $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "Group '$($memberGrp.DisplayName)' removed from '$($grp.DisplayName)'" })
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "Group '$mid': $($_.Exception.Message)" }) }
                }
            }

            if ($null -ne $UserIds) {
                foreach ($uid in $UserIds) {
                    try { $usr = Get-MailUser -Identity $uid -ErrorAction Stop }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$uid' not found: $($_.Exception.Message)" }); continue }

                    try {
                        $null = Remove-DistributionGroupMember -Identity $gid -Member $uid -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                        $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Success"; Message = "User '$($usr.DisplayName)' removed from '$($grp.DisplayName)'" })
                    }
                    catch { $null = $results.Add([PSCustomObject]@{ Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Status = "Error"; Message = "User '$uid': $($_.Exception.Message)" }) }
                }
            }
        }

        Write-Output $results
    }
    catch { throw }
}
