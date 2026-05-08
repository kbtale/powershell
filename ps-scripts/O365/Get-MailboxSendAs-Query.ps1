#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Query-format list of mailbox SendAs permissions
.DESCRIPTION
    Returns users with SendAs permission to a specified mailbox as Value/DisplayValue pairs for use in dropdown selectors.
.PARAMETER MailboxId
    User principal name of the mailbox
.EXAMPLE
    PS> ./Get-MailboxSendAs-Query.ps1 -MailboxId "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

Process {
    try {
        $users = Get-RecipientPermission -Identity $MailboxId -ErrorAction Stop | Select-Object -ExpandProperty Trustee | Get-Mailbox -SortBy DisplayName -ErrorAction SilentlyContinue | Select-Object DisplayName, UserPrincipalName

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
