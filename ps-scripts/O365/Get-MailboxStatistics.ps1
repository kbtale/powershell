#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange Online: Gets mailbox statistics for a specified mailbox
.DESCRIPTION
    Retrieves statistics for a mailbox from Exchange Online, including item counts, sizes, and quota information. Optionally returns statistics for the archive mailbox.
.PARAMETER MailboxId
    Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox
.PARAMETER Archive
    Return mailbox statistics for the archive mailbox associated with the specified mailbox
.EXAMPLE
    PS> ./Get-MailboxStatistics.ps1 -MailboxId "user@domain.com"
.EXAMPLE
    PS> ./Get-MailboxStatistics.ps1 -MailboxId "user@domain.com" -Archive
.CATEGORY O365
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$Archive
)

Process {
    try {
        $box = Get-Mailbox -Identity $MailboxId -ErrorAction Stop
        if ($null -eq $box) {
            throw "Mailbox not found"
        }
        $result = Get-MailboxStatistics -Identity $MailboxId -Archive:$Archive -ErrorAction Stop
        $result | ForEach-Object {
            $_ | Add-Member -NotePropertyName Timestamp -NotePropertyValue (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -PassThru -Force
        }
    }
    catch { throw }
}
