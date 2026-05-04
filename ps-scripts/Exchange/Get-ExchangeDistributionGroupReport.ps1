#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Generates a detailed audit report of Distribution Groups

.DESCRIPTION
    Retrieves a comprehensive set of properties for all Distribution Groups, including group types, organizational units, and aliases.

.EXAMPLE
    PS> ./Get-ExchangeDistributionGroupReport.ps1

.CATEGORY Exchange
#>

[CmdletBinding()]
Param ()

Process {
    try {
        $groups = Get-DistributionGroup -ErrorAction Stop

        $results = foreach ($g in $groups) {
            [PSCustomObject]@{
                Name                 = $g.Name
                DisplayName          = $g.DisplayName
                Alias                = $g.Alias
                GroupType            = $g.GroupType
                RecipientTypeDetails = $g.RecipientTypeDetails
                PrimarySmtpAddress   = $g.PrimarySmtpAddress
                ManagedBy            = $g.ManagedBy
                OrganizationalUnit   = $g.OrganizationalUnit
                DistinguishedName    = $g.DistinguishedName
                LastModified         = $g.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object Name)
    }
    catch {
        throw
    }
}
