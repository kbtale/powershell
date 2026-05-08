#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Query-format list of mailbox full access permissions
.DESCRIPTION
    Returns users with FullAccess permission to a specified mailbox as Value/DisplayValue pairs for use in dropdown selectors.
.PARAMETER MailboxId
    User principal name of the mailbox
.EXAMPLE
    PS> ./Get-MailboxFullAccess-Query.ps1 -MailboxId "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

Process {
    try {
        $perms = Get-MailboxPermission -Identity $MailboxId -ErrorAction Stop | Select-Object AccessRights, User -ExpandProperty User

        foreach ($perm in $perms) {
            $user = Get-Mailbox -Identity $perm.User -ErrorAction SilentlyContinue | Select-Object DisplayName, UserPrincipalName
            if ($null -ne $user) {
                [PSCustomObject]@{
                    Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Value        = $user.UserPrincipalName
                    DisplayValue = "$($user.DisplayName) - $($perm.AccessRights)"
                }
            }
        }
    }
    catch { throw }
}
