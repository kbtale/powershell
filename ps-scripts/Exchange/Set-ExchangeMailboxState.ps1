#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Enables or disables a mailbox

.DESCRIPTION
    Activates a mailbox for an existing user or disables an existing mailbox. Disabling a mailbox removes Exchange attributes but preserves the Active Directory user object.

.PARAMETER Identity
    Specifies the Identity of the user or mailbox.

.PARAMETER Action
    Specifies whether to Enable or Disable the mailbox.

.PARAMETER Type
    Specifies the type of mailbox to create when enabling (e.g., Regular, Shared, Room, Equipment).

.PARAMETER Database
    Optional. Specifies the Exchange database for the mailbox (On-Premises only).

.EXAMPLE
    PS> ./Set-ExchangeMailboxState.ps1 -Identity "user@contoso.com" -Action Enable

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Enable', 'Disable')]
    [string]$Action,

    [ValidateSet('Regular', 'Shared', 'Room', 'Equipment')]
    [string]$Type = 'Regular',

    [string]$Database
)

Process {
    try {
        if ($Action -eq 'Enable') {
            $params = @{
                'Identity'    = $Identity
                'Confirm'     = $false
                'ErrorAction' = 'Stop'
            }
            if ($Database) { $params.Add('Database', $Database) }
            if ($Type -ne 'Regular') { $params.Add($Type, $true) }

            Enable-Mailbox @params
        }
        else {
            Disable-Mailbox -Identity $Identity -Confirm:$false -ErrorAction Stop
        }

        $status = if ($Action -eq 'Enable') { "Enabled" } else { "Disabled" }
        $result = [PSCustomObject]@{
            Identity  = $Identity
            Action    = "Mailbox$status"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
