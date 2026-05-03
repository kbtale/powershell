#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Configures archive settings for a mailbox

.DESCRIPTION
    Enables or disables the archive mailbox for a specified user. Supports specifying a target archive database for on-premises deployments.

.PARAMETER Identity
    Specifies the Identity of the mailbox (Alias, Email, GUID, etc.).

.PARAMETER Archive
    Specifies whether the archive should be enabled ($true) or disabled ($false).

.PARAMETER ArchiveDatabase
    Optional. Specifies the Exchange database to hold the archive mailbox (On-Premises only).

.PARAMETER ArchiveName
    Optional. Specifies a custom name for the archive mailbox.

.EXAMPLE
    PS> ./Set-ExchangeMailboxArchiveConfig.ps1 -Identity "user@contoso.com" -Archive $true

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [bool]$Archive,

    [string]$ArchiveDatabase,

    [string]$ArchiveName
)

Process {
    try {
        if ($Archive) {
            $params = @{
                'Identity'    = $Identity
                'Archive'     = $true
                'Confirm'     = $false
                'ErrorAction' = 'Stop'
            }
            if ($ArchiveDatabase) { $params.Add('ArchiveDatabase', $ArchiveDatabase) }
            if ($ArchiveName) { $params.Add('ArchiveName', $ArchiveName) }

            Enable-Mailbox @params
        }
        else {
            Disable-Mailbox -Identity $Identity -Archive -Confirm:$false -ErrorAction Stop
        }

        $mailbox = Get-Mailbox -Identity $Identity -ErrorAction Stop
        $result = [PSCustomObject]@{
            Identity     = $Identity
            ArchiveState = $mailbox.ArchiveState
            ArchiveName  = $mailbox.ArchiveName
            Action       = "ArchiveConfigUpdated"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
