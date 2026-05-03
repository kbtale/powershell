#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Configures Automatic Replies (Out of Office) for a mailbox

.DESCRIPTION
    Enables, disables, or schedules Out of Office (OOF) replies for a specified mailbox. Supports distinct internal and external messages and audience targeting.

.PARAMETER Identity
    Specifies the Identity of the mailbox.

.PARAMETER State
    Specifies the state of the automatic replies (Enabled, Disabled, Scheduled).

.PARAMETER InternalMessage
    Specifies the automatic reply message sent to internal senders.

.PARAMETER ExternalMessage
    Specifies the automatic reply message sent to external senders.

.PARAMETER ExternalAudience
    Specifies the audience for external automatic replies (None, Known, All).

.PARAMETER StartTime
    Specifies the start time for scheduled automatic replies.

.PARAMETER EndTime
    Specifies the end time for scheduled automatic replies.

.EXAMPLE
    PS> ./Set-ExchangeMailboxOutOfOfficeConfig.ps1 -Identity "user1" -State Enabled -InternalMessage "I am out of the office."

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Enabled', 'Disabled', 'Scheduled')]
    [string]$State,

    [string]$InternalMessage,

    [string]$ExternalMessage,

    [ValidateSet('None', 'Known', 'All')]
    [string]$ExternalAudience = 'All',

    [datetime]$StartTime,

    [datetime]$EndTime
)

Process {
    try {
        $params = @{
            'Identity'        = $Identity
            'AutoReplyState'  = $State
            'Confirm'         = $false
            'ErrorAction'     = 'Stop'
        }

        if ($State -ne 'Disabled') {
            if ($InternalMessage) { $params.Add('InternalMessage', $InternalMessage) }
            if ($ExternalMessage) { $params.Add('ExternalMessage', $ExternalMessage) }
            $params.Add('ExternalAudience', $ExternalAudience)

            if ($State -eq 'Scheduled') {
                if (-not $StartTime -or -not $EndTime) {
                    throw "StartTime and EndTime are required when State is 'Scheduled'."
                }
                $params.Add('StartTime', $StartTime)
                $params.Add('EndTime', $EndTime)
            }
        }

        Set-MailboxAutoReplyConfiguration @params

        $config = Get-MailboxAutoReplyConfiguration -Identity $Identity -ErrorAction Stop
        $result = [PSCustomObject]@{
            Identity       = $Identity
            AutoReplyState = $config.AutoReplyState
            StartTime      = $config.StartTime
            EndTime        = $config.EndTime
            Action         = "OOFConfigUpdated"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
