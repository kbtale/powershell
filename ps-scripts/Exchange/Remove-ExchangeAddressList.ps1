#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Deletes an Address List

.DESCRIPTION
    Removes a Microsoft Exchange Address List identified by its name, GUID, or Distinguished Name. Optionally removes child address lists recursively.

.PARAMETER Identity
    Specifies the Identity of the address list to remove.

.PARAMETER Recursive
    If set, removes the specified address list and all its child address lists.

.EXAMPLE
    PS> ./Remove-ExchangeAddressList.ps1 -Identity "Old Address List"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [switch]$Recursive
)

Process {
    try {
        $params = @{
            'Identity'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }
        if ($Recursive.IsPresent) { $params.Add('Recursive', $true) }

        Remove-AddressList @params

        $result = [PSCustomObject]@{
            Identity     = $Identity
            Action       = "AddressListRemoved"
            Status       = "Success"
            Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
