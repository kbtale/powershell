#Requires -Version 5.1

<#
.SYNOPSIS
    Security: Audits all members of the local Administrators group
.DESCRIPTION
    Audits the local Administrators group (using well-known SID S-1-5-32-544 to support localized systems) and compares members against an approved baseline list, flagging unauthorized accounts.
.PARAMETER AllowedAccounts
    An array of usernames or group names that are approved to hold local administrative rights.
.EXAMPLE
    PS> ./Get-LocalAdminAudit.ps1 -AllowedAccounts "Administrator", "Domain Admins", "CeBeM"
.CATEGORY Security
#>

[CmdletBinding()]
Param(
    [string[]]$AllowedAccounts = @('Administrator')
)

Process {
    try {
        # Localization-safe retrieval of the local Administrators group name via well-known SID S-1-5-32-544
        $adminSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
        $adminGroupTranslated = $adminSid.Translate([System.Security.Principal.NTAccount]).Value
        $adminGroupName = $adminGroupTranslated.Split('\')[-1]

        Write-Verbose "Resolved local Administrators group name as: $adminGroupName"

        $members = Get-LocalGroupMember -Group $adminGroupName -ErrorAction Stop
        
        $results = @()
        foreach ($member in $members) {
            # Extract just the account name without domain/computer prefix if present
            $shortName = $member.Name.Split('\')[-1]
            
            # Check if member is in the allowed list (case-insensitive)
            $isAllowed = $false
            if ($AllowedAccounts -contains $member.Name -or $AllowedAccounts -contains $shortName) {
                $isAllowed = $true
            }

            # Gather additional user enablement info if local user
            $enabledState = "N/A (Group or Domain Object)"
            if ($member.PrincipalSource -eq 'Local' -and $member.ObjectClass -eq 'User') {
                $localUser = Get-LocalUser -Name $shortName -ErrorAction SilentlyContinue
                if ($localUser) {
                    $enabledState = $localUser.Enabled
                }
            }

            $results += [PSCustomObject]@{
                GroupMatched    = $adminGroupName
                MemberName      = $member.Name
                ObjectClass     = $member.ObjectClass
                PrincipalSource = $member.PrincipalSource
                SID             = $member.SID.Value
                IsEnabled       = $enabledState
                IsApproved      = $isAllowed
                Status          = if ($isAllowed) { "Approved" } else { "WARNING: Unauthorized Administrator!" }
            }
        }

        Write-Output $results
    }
    catch {
        Write-Error $_
        throw
    }
}
