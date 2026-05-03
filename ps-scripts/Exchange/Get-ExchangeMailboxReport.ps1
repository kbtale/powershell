#Requires -Version 5.1

<#
.SYNOPSIS
    Exchange: Generates a detailed audit report of all mailboxes

.DESCRIPTION
    Retrieves a comprehensive set of properties for all mailboxes in the organization. Supports filtering by mailbox status and resource type.

.PARAMETER EnabledOnly
    If set, includes only mailboxes where IsMailboxEnabled is true.

.PARAMETER ExcludeResources
    If set, excludes resource mailboxes (Rooms and Equipment) from the report.

.EXAMPLE
    PS> ./Get-ExchangeMailboxReport.ps1 -EnabledOnly

.CATEGORY Exchange
#>

[CmdletBinding()]
Param (
    [switch]$EnabledOnly,
    [switch]$ExcludeResources
)

Process {
    try {
        $mailboxes = Get-Mailbox -ResultSize Unlimited -ErrorAction Stop

        if ($EnabledOnly.IsPresent) {
            $mailboxes = $mailboxes | Where-Object { $_.IsMailboxEnabled -eq $true }
        }
        if ($ExcludeResources.IsPresent) {
            $mailboxes = $mailboxes | Where-Object { $_.IsResource -eq $false }
        }

        $results = foreach ($mb in $mailboxes) {
            [PSCustomObject]@{
                DisplayName          = $mb.DisplayName
                Alias                = $mb.Alias
                PrimarySmtpAddress   = $mb.PrimarySmtpAddress
                RecipientTypeDetails = $mb.RecipientTypeDetails
                Database             = $mb.Database.Name
                IsMailboxEnabled     = $mb.IsMailboxEnabled
                IsResource           = $mb.IsResource
                ArchiveStatus        = $mb.ArchiveStatus
                LastModified         = $mb.WhenChanged
            }
        }

        Write-Output ($results | Sort-Object DisplayName)
    }
    catch {
        throw
    }
}
