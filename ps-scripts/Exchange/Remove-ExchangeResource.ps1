#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Deletes a Resource Mailbox

.DESCRIPTION
    Removes a Microsoft Exchange resource mailbox (Room or Equipment). Supports permanent deletion (bypassing the recycle bin).

.PARAMETER Identity
    Specifies the Identity of the resource mailbox to remove.

.PARAMETER Permanent
    If set, permanently deletes the mailbox, bypassing the recycle bin/soft-delete state.

.EXAMPLE
    PS> ./Remove-ExchangeResource.ps1 -Identity "Room 101" -Permanent

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [switch]$Permanent
)

Process {
    try {
        $params = @{
            'Identity'    = $Identity
            'Permanent'   = $Permanent.IsPresent
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }

        Remove-Mailbox @params

        $result = [PSCustomObject]@{
            Identity  = $Identity
            Action    = "ResourceRemoved"
            Status    = "Success"
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
