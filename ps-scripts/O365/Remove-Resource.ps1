#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Removes a resource mailbox
.DESCRIPTION
    Removes a resource mailbox from Exchange Online. Optionally performs a permanent deletion from the database.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource to remove
.PARAMETER Permanent
    Permanently delete the resource from the database
.EXAMPLE
    PS> ./Remove-Resource.ps1 -MailboxId "ConfRoom1@domain.com"
.EXAMPLE
    PS> ./Remove-Resource.ps1 -MailboxId "ConfRoom1@domain.com" -Permanent
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
        $null = Remove-Mailbox -Identity $MailboxId -Permanent:$Permanent -Force -Confirm:$false -ErrorAction Stop

        [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Message   = "Resource $($MailboxId) removed"
        }
    }
    catch { throw }
}
