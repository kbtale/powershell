#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Configures storage quotas for a mailbox

.DESCRIPTION
    Sets storage limits and warning thresholds for an Exchange mailbox, including recoverable items and archives. Supports numeric values with units (e.g., 50GB).

.PARAMETER Identity
    Specifies the Identity of the mailbox.

.PARAMETER UseDatabaseDefaults
    If set, the mailbox uses the quota defaults defined on the database level.

.PARAMETER IssueWarningQuota
    Specifies the threshold at which a warning is issued to the user.

.PARAMETER ProhibitSendQuota
    Specifies the threshold at which the user can no longer send messages.

.PARAMETER ProhibitSendReceiveQuota
    Specifies the threshold at which the user can no longer send or receive messages.

.PARAMETER ArchiveQuota
    Specifies the maximum size for the archive mailbox.

.PARAMETER ArchiveWarningQuota
    Specifies the warning threshold for the archive mailbox.

.EXAMPLE
    PS> ./Set-ExchangeMailboxQuotaConfig.ps1 -Identity "user1" -ProhibitSendReceiveQuota 50GB -IssueWarningQuota 45GB

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [switch]$UseDatabaseDefaults,

    [string]$IssueWarningQuota,
    [string]$ProhibitSendQuota,
    [string]$ProhibitSendReceiveQuota,
    [string]$ArchiveQuota,
    [string]$ArchiveWarningQuota,
    [string]$RecoverableItemsQuota,
    [string]$RecoverableItemsWarningQuota
)

Process {
    try {
        $params = @{
            'Identity'                 = $Identity
            'UseDatabaseQuotaDefaults' = $UseDatabaseDefaults.IsPresent
            'Confirm'                  = $false
            'ErrorAction'              = 'Stop'
        }

        if (-not $UseDatabaseDefaults) {
            if ($IssueWarningQuota) { $params.Add('IssueWarningQuota', $IssueWarningQuota) }
            if ($ProhibitSendQuota) { $params.Add('ProhibitSendQuota', $ProhibitSendQuota) }
            if ($ProhibitSendReceiveQuota) { $params.Add('ProhibitSendReceiveQuota', $ProhibitSendReceiveQuota) }
            if ($ArchiveQuota) { $params.Add('ArchiveQuota', $ArchiveQuota) }
            if ($ArchiveWarningQuota) { $params.Add('ArchiveWarningQuota', $ArchiveWarningQuota) }
            if ($RecoverableItemsQuota) { $params.Add('RecoverableItemsQuota', $RecoverableItemsQuota) }
            if ($RecoverableItemsWarningQuota) { $params.Add('RecoverableItemsWarningQuota', $RecoverableItemsWarningQuota) }
        }

        Set-Mailbox @params

        $mailbox = Get-Mailbox -Identity $Identity -ErrorAction Stop
        $result = [PSCustomObject]@{
            Identity                 = $Identity
            UseDatabaseQuotaDefaults = $mailbox.UseDatabaseQuotaDefaults
            IssueWarningQuota        = $mailbox.IssueWarningQuota
            ProhibitSendQuota        = $mailbox.ProhibitSendQuota
            ProhibitSendReceiveQuota = $mailbox.ProhibitSendReceiveQuota
            Action                   = "QuotaConfigUpdated"
            Status                   = "Success"
            Timestamp                = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
