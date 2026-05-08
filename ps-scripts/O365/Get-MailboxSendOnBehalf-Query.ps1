#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Query-format list of mailbox SendOnBehalf permissions
.DESCRIPTION
    Returns users with SendOnBehalf permission to a specified mailbox as Value/DisplayValue pairs for use in dropdown selectors.
.PARAMETER MailboxId
    User principal name of the mailbox
.EXAMPLE
    PS> ./Get-MailboxSendOnBehalf-Query.ps1 -MailboxId "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

Process {
    try {
        $grantList = (Get-Mailbox -Identity $MailboxId -ErrorAction Stop).GrantSendOnBehalfTo
        $users = $grantList | Get-Mailbox -SortBy DisplayName -ErrorAction SilentlyContinue | Select-Object DisplayName, UserPrincipalName

        foreach ($itm in $users) {
            [PSCustomObject]@{
                Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Value        = $itm.UserPrincipalName
                DisplayValue = $itm.DisplayName
            }
        }
    }
    catch { throw }
}
