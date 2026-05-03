#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Lists all Distribution Groups in the organization

.DESCRIPTION
    Retrieves an inventory of all Microsoft Exchange Distribution Groups. Supports filtering by name or other properties.

.PARAMETER Filter
    Specifies an optional filter to apply to the retrieval.

.EXAMPLE
    PS> ./Get-ExchangeDistributionGroup.ps1

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

        $groups = Get-DistributionGroup @params

        $results = foreach ($g in $groups) {
            [PSCustomObject]@{
                Name           = $g.Name
                DisplayName    = $g.DisplayName
                Alias          = $g.Alias
                PrimarySmtpAddress = $g.PrimarySmtpAddress
                GroupType      = $g.GroupType
                RecipientTypeDetails = $g.RecipientTypeDetails
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
