#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Configures email forwarding for a mailbox

.DESCRIPTION
    Configures server-side email forwarding for a specified mailbox. Supports both standard forwarding (Set-Mailbox) and Inbox rules (New-InboxRule).

.PARAMETER Identity
    Specifies the Identity of the mailbox to forward from.

.PARAMETER ForwardTo
    Specifies the Identity of the recipient to forward messages to.

.PARAMETER DeliverToMailboxAndForward
    If set, a copy of the forwarded messages will be kept in the original mailbox.

.PARAMETER UseInboxRule
    If set, creates an Inbox rule instead of using the standard ForwardingAddress attribute.

.PARAMETER RuleName
    Optional. Specifies the name for the Inbox rule if UseInboxRule is enabled.

.EXAMPLE
    PS> ./Set-ExchangeMailboxForwardConfig.ps1 -Identity "user1" -ForwardTo "user2" -DeliverToMailboxAndForward $true

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [string]$ForwardTo,

    [bool]$DeliverToMailboxAndForward = $true,

    [switch]$UseInboxRule,

    [string]$RuleName
)

Process {
    try {
        if ($UseInboxRule.IsPresent) {
            $name = if ($RuleName) { $RuleName } else { "Forward to $ForwardTo" }
            New-InboxRule -Mailbox $Identity -Name $name -ForwardTo $ForwardTo -Confirm:$false -ErrorAction Stop
        }
        else {
            Set-Mailbox -Identity $Identity -ForwardingAddress $ForwardTo -DeliverToMailboxAndForward $DeliverToMailboxAndForward -Confirm:$false -ErrorAction Stop
        }

        $result = [PSCustomObject]@{
            Identity          = $Identity
            ForwardTo         = $ForwardTo
            ForwardingType    = if ($UseInboxRule) { "InboxRule" } else { "ForwardingAddress" }
            Action            = "ForwardingConfigured"
            Status            = "Success"
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
