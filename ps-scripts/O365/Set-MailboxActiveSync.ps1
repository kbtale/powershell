#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Enables or disables ActiveSync for a mailbox
.DESCRIPTION
    Sets the Exchange ActiveSync enabled state for a specified mailbox in Exchange Online.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox
.PARAMETER Activate
    Enable or disable Exchange ActiveSync for the mailbox
.EXAMPLE
    PS> ./Set-MailboxActiveSync.ps1 -MailboxId "user@domain.com" -Activate $true
.EXAMPLE
    PS> ./Set-MailboxActiveSync.ps1 -MailboxId "user@domain.com" -Activate $false
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [bool]$Activate
)

Process {
    try {
        $box = Get-CASMailbox -Identity $MailboxId -ErrorAction Stop
        if ($null -eq $box) {
            throw "Mailbox not found"
        }
        $null = Set-CASMailbox -Identity $MailboxId -ActiveSyncEnabled $Activate -ErrorAction Stop
        $result = Get-CASMailbox -Identity $MailboxId -ErrorAction Stop | Select-Object ActiveSyncEnabled, PrimarySmtpAddress, DisplayName
        $result | ForEach-Object {
            $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
