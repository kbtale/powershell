#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Lists all mailboxes in the organization

.DESCRIPTION
    Retrieves an inventory of all Microsoft Exchange mailboxes. Supports filtering by name, type, or database.

.PARAMETER Filter
    Optional. Specifies an OPATH filter to apply to the retrieval.

.PARAMETER ResultSize
    Optional. Specifies the maximum number of results to return. Defaults to Unlimited.

.EXAMPLE
    PS> ./Get-ExchangeMailbox.ps1 -Filter "RecipientTypeDetails -eq 'SharedMailbox'"

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [string]$Filter,

    [string]$ResultSize = 'Unlimited'
)

Process {
    try {
        $params = @{
            'ResultSize'  = $ResultSize
            'ErrorAction' = 'Stop'
        }
        if ($Filter) { $params.Add('Filter', $Filter) }

        $mailboxes = Get-Mailbox @params

        $results = foreach ($mb in $mailboxes) {
            [PSCustomObject]@{
                DisplayName          = $mb.DisplayName
                Alias                = $mb.Alias
                PrimarySmtpAddress   = $mb.PrimarySmtpAddress
                RecipientTypeDetails = $mb.RecipientTypeDetails
                Database             = $mb.Database.Name
                IsResource           = $mb.IsResource
                LastModified         = $mb.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
