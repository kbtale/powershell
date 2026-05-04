#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Creates a new Address List

.DESCRIPTION
    Creates a new Microsoft Exchange Address List with specified recipient filters. Supports filtering by recipient types such as mailboxes, contacts, and groups.

.PARAMETER Name
    Specifies the unique name of the address list.

.PARAMETER DisplayName
    Specifies the display name of the address list. Defaults to the Name if not specified.

.PARAMETER IncludedRecipients
    Specifies the types of recipients to include in the address list. Defaults to 'AllRecipients'.

.PARAMETER Container
    Specifies the path to the container where the address list is created.

.EXAMPLE
    PS> ./New-ExchangeAddressList.ps1 -Name "HR Department" -IncludedRecipients MailboxUsers

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$DisplayName,

    [ValidateSet('None', 'AllRecipients', 'MailboxUsers', 'Resources', 'MailContacts', 'MailGroups', 'MailUsers')]
    [string[]]$IncludedRecipients = @('AllRecipients'),

    [string]$Container
)

Process {
    try {
        $params = @{
            'Name'               = $Name
            'DisplayName'        = if ($DisplayName) { $DisplayName } else { $Name }
            'IncludedRecipients' = $IncludedRecipients
            'Confirm'            = $false
            'ErrorAction'        = 'Stop'
        }
        if ($Container) { $params.Add('Container', $Container) }

        $addressList = New-AddressList @params

        $result = [PSCustomObject]@{
            Name           = $addressList.Name
            DisplayName    = $addressList.DisplayName
            DistinguishedName = $addressList.DistinguishedName
            Action         = "AddressListCreated"
            Status         = "Success"
            Timestamp      = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
