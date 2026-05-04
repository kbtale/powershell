#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Modifies an existing Address List

.DESCRIPTION
    Updates properties and recipient filters for an existing Microsoft Exchange Address List.

.PARAMETER Identity
    Specifies the Identity of the address list to modify.

.PARAMETER DisplayName
    Specifies a new display name for the address list.

.PARAMETER IncludedRecipients
    Specifies the types of recipients to include.

.PARAMETER ForceUpgrade
    If set, forces the upgrade of a legacy address list to the current version.

.EXAMPLE
    PS> ./Set-ExchangeAddressListConfig.ps1 -Identity "\HR" -IncludedRecipients MailboxUsers,MailGroups

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string]$DisplayName,

    [ValidateSet('None', 'AllRecipients', 'MailboxUsers', 'Resources', 'MailContacts', 'MailGroups', 'MailUsers')]
    [string[]]$IncludedRecipients,

    [switch]$ForceUpgrade
)

Process {
    try {
        $params = @{
            'Identity'    = $Identity
            'Confirm'     = $false
            'ErrorAction' = 'Stop'
        }
        if ($DisplayName) { $params.Add('DisplayName', $DisplayName) }
        if ($IncludedRecipients) { $params.Add('IncludedRecipients', $IncludedRecipients) }
        if ($ForceUpgrade.IsPresent) { $params.Add('ForceUpgrade', $true) }

        if ($params.Count -gt 3) {
            Set-AddressList @params
        }

        $addressList = Get-AddressList -Identity $Identity -ErrorAction Stop
        
        $result = [PSCustomObject]@{
            Name           = $addressList.Name
            DisplayName    = $addressList.DisplayName
            IncludedRecipients = $addressList.IncludedRecipients
            Action         = "AddressListUpdated"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
