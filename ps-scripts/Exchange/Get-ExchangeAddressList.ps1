#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Lists all Address Lists in the Exchange organization

.DESCRIPTION
    Retrieves a list of all Address Lists configured in Microsoft Exchange. Supports basic property selection and sorting.

.PARAMETER Filter
    Specifies an optional filter to apply to the Address List retrieval.

.EXAMPLE
    PS> ./Get-ExchangeAddressList.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [string]$Filter
)

Process {
    try {
        $params = @{
            'ErrorAction' = 'Stop'
        }
        if ($Filter) { $params.Add('Filter', $Filter) }

        $addressLists = Get-AddressList @params

        $results = foreach ($al in $addressLists) {
            [PSCustomObject]@{
                Name           = $al.Name
                DisplayName    = $al.DisplayName
                Path           = $al.Path
                IsValid        = $al.IsValid
                LastModified   = $al.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
