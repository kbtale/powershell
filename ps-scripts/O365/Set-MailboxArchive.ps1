#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Enables or disables the archive mailbox
.DESCRIPTION
    Enables or disables the archive mailbox for a specified mailbox in Exchange Online.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox
.PARAMETER Enable
    Enables the archive mailbox. If not specified, disables the archive.
.EXAMPLE
    PS> ./Set-MailboxArchive.ps1 -MailboxId "user@domain.com" -Enable
.EXAMPLE
    PS> ./Set-MailboxArchive.ps1 -MailboxId "user@domain.com"
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Enable
)

Process {
    try {
        $box = Get-Mailbox -Identity $MailboxId -ErrorAction Stop
        if ($null -eq $box) {
            throw "Mailbox not found"
        }
        if ($Enable) {
            $null = Enable-Mailbox -Identity $MailboxId -Archive -Confirm:$false -ErrorAction Stop
        }
        else {
            $null = Disable-Mailbox -Identity $MailboxId -Archive -Confirm:$false -ErrorAction Stop
        }
        $result = Get-Mailbox -Identity $MailboxId -ErrorAction Stop | Select-Object ArchiveStatus, UserPrincipalName, DisplayName, WindowsEmailAddress
        $result | ForEach-Object {
            $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
