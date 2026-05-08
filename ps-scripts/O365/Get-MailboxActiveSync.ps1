#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Retrieves ActiveSync settings for a mailbox
.DESCRIPTION
    Gets the ActiveSync enabled status and primary SMTP address for a mailbox.
.PARAMETER MailboxId
    Identity of the mailbox (alias, display name, DN, SAM, GUID, or UPN)
.EXAMPLE
    PS> ./Get-MailboxActiveSync.ps1 -MailboxId "john.doe@contoso.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId
)

Process {
    try {
        $result = Get-CASMailbox -Identity $MailboxId -ErrorAction Stop | Select-Object ActiveSyncEnabled, PrimarySmtpAddress, DisplayName

        [PSCustomObject]@{
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ActiveSyncEnabled  = $result.ActiveSyncEnabled
            PrimarySmtpAddress = $result.PrimarySmtpAddress
            DisplayName        = $result.DisplayName
        }
    }
    catch { throw }
}
