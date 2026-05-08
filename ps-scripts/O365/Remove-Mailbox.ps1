#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Removes a mailbox
.DESCRIPTION
    Removes a mailbox from Exchange Online. Optionally performs a permanent removal from the database.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox to remove
.PARAMETER Permanent
    Permanently removes the mailbox from the database
.EXAMPLE
    PS> ./Remove-Mailbox.ps1 -MailboxId "user@domain.com"
.EXAMPLE
    PS> ./Remove-Mailbox.ps1 -MailboxId "user@domain.com" -Permanent
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Permanent
)

Process {
    try {
        $box = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object UserPrincipalName, DisplayName
        if ($null -eq $box) {
            throw "Mailbox not found"
        }
        $null = Remove-Mailbox -Identity $box.UserPrincipalName -Permanent:$Permanent -Confirm:$false -Force -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Message   = "Mailbox $($box.DisplayName) removed"
        }
    }
    catch { throw }
}
