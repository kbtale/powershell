#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Generates a detailed audit report of Address Lists

.DESCRIPTION
    Retrieves a comprehensive set of properties for all Address Lists, including recipient filters and path information.

.EXAMPLE
    PS> ./Get-ExchangeAddressListReport.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $addressLists = Get-AddressList -ErrorAction Stop

        $results = foreach ($al in $addressLists) {
            [PSCustomObject]@{
                Name               = $al.Name
                DisplayName        = $al.DisplayName
                IncludedRecipients = $al.IncludedRecipients
                RecipientFilter    = $al.RecipientFilter
                Path               = $al.Path
                IsValid            = $al.IsValid
                DistinguishedName  = $al.DistinguishedName
                LastModified       = $al.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
