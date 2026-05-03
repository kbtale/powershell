#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Retrieves detailed properties of an Exchange Address List

.DESCRIPTION
    Gets properties for a specific Microsoft Exchange Address List identified by its name, GUID, or Distinguished Name.

.PARAMETER Identity
    Specifies the Identity of the address list (Name, Display Name, GUID, or DN).

.PARAMETER Properties
    Specifies an array of properties to retrieve. Defaults to a standard set of administrative properties. Use '*' for all.

.EXAMPLE
    PS> ./Get-ExchangeAddressListInfo.ps1 -Identity "\All Users"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string[]]$Properties = @('Name', 'DisplayName', 'IncludedRecipients', 'Path', 'IsValid', 'DistinguishedName', 'Guid')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        $addressList = Get-AddressList -Identity $Identity -ErrorAction Stop
        $result = $addressList | Select-Object $Properties

        if ($null -eq $result) {
            throw "Address list '$Identity' not found or properties could not be retrieved."
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
