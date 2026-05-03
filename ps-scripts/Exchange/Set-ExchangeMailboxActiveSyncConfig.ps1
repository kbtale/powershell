#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Configures ActiveSync settings for a mailbox

.DESCRIPTION
    Enables or disables Exchange ActiveSync for a specified mailbox and optionally applies an ActiveSync mailbox policy.

.PARAMETER Identity
    Specifies the Identity of the mailbox (Alias, Email, GUID, etc.).

.PARAMETER Enabled
    Specifies whether ActiveSync should be enabled ($true) or disabled ($false).

.PARAMETER Policy
    Optionally specifies the ActiveSync mailbox policy to apply.

.EXAMPLE
    PS> ./Set-ExchangeMailboxActiveSyncConfig.ps1 -Identity "user@contoso.com" -Enabled $true

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [bool]$Enabled,

    [string]$Policy
)

Process {
    try {
        $params = @{
            'Identity'          = $Identity
            'ActiveSyncEnabled' = $Enabled
            'Confirm'           = $false
            'ErrorAction'       = 'Stop'
        }
        if ($Policy) { $params.Add('ActiveSyncMailboxPolicy', $Policy) }

        Set-CASMailbox @params

        $mailbox = Get-CASMailbox -Identity $Identity -ErrorAction Stop
        $result = [PSCustomObject]@{
            Identity          = $Identity
            ActiveSyncEnabled = $mailbox.ActiveSyncEnabled
            Policy            = $mailbox.ActiveSyncMailboxPolicy
            Action            = "ActiveSyncConfigUpdated"
            Status            = "Success"
            Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
