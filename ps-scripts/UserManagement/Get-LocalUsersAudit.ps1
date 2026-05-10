#Requires -Version 5.1

<#
.SYNOPSIS
    User Management: Audits all local user accounts on the machine
.DESCRIPTION
    Queries all local Windows user accounts and details their enablement state, password security flags, and (optionally) local group memberships.
.PARAMETER IncludeGroups
    Retrieve and include a list of local security groups that each user belongs to
.EXAMPLE
    PS> ./Get-LocalUsersAudit.ps1 -IncludeGroups
.CATEGORY User Management
#>

[CmdletBinding()]
Param(
    [switch]$IncludeGroups
)

Process {
    try {
        $localUsers = Get-LocalUser -ErrorAction Stop
        $allGroups = if ($IncludeGroups) { Get-LocalGroup -ErrorAction SilentlyContinue } else { $null }

        $results = foreach ($user in $localUsers) {
            $userGroups = @()
            if ($IncludeGroups -and $allGroups) {
                foreach ($g in $allGroups) {
                    $members = Get-LocalGroupMember -Group $g -ErrorAction SilentlyContinue
                    # Check both short name and ComputerName\Name format
                    if ($members.Name -contains $user.Name -or 
                        $members.Name -contains "$env:COMPUTERNAME\$($user.Name)") {
                        $userGroups += $g.Name
                    }
                }
            }

            [PSCustomObject]@{
                Username             = $user.Name
                FullName             = $user.FullName
                Enabled              = $user.Enabled
                Description          = $user.Description
                PasswordRequired     = $user.PasswordRequired
                PasswordNeverExpires = $user.PasswordNeverExpires
                PasswordLastSet      = $user.PasswordLastSet
                LastLogon            = $user.LastLogon
                LocalGroups          = if ($IncludeGroups) { $userGroups -join ', ' } else { 'Not Requested' }
            }
        }

        Write-Output $results
    }
    catch {
        Write-Error $_
        throw
    }
}
