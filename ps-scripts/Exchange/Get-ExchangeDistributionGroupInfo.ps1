#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Retrieves detailed properties of a Distribution Group

.DESCRIPTION
    Gets properties for a specific Microsoft Exchange Distribution Group identified by its name, alias, email address, GUID, or Distinguished Name.

.PARAMETER Identity
    Specifies the Identity of the distribution group.

.PARAMETER Properties
    Specifies an array of properties to retrieve. Defaults to standard administrative properties. Use '*' for all.

.EXAMPLE
    PS> ./Get-ExchangeDistributionGroupInfo.ps1 -Identity "Sales"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string[]]$Properties = @('Name', 'Alias', 'DisplayName', 'PrimarySmtpAddress', 'RecipientTypeDetails', 'GroupType', 'ManagedBy', 'IsValid', 'DistinguishedName', 'Guid')
)

Process {
    try {
        if ($Properties -contains '*') {
            $Properties = @('*')
        }

        $group = Get-DistributionGroup -Identity $Identity -ErrorAction Stop
        $result = $group | Select-Object $Properties

        if ($null -eq $result) {
            throw "Distribution Group '$Identity' not found or properties could not be retrieved."
        }

        Write-Output $result
    }
    catch {
        throw
    }
}
